#!/usr/bin/env python3
"""
XSSMaze Benchmark Tool

Runs an XSS scanner against a running XSSMaze instance and prints a scorecard.

The scorecard is built from the structured vulnerability metadata XSSMaze
already serves on /map/json, because two populations in the catalog must not
be counted as detection misses:

  * `vuln.exploitable == false` endpoints are deliberate true negatives (the
    `non-xss-control` class). Reporting nothing there is *correct* behaviour,
    so they are removed from the denominator entirely and a detection on one
    is scored as a false positive instead.
  * `vuln.reach == "client"` endpoints take their payload from a browser-only
    channel (fragment, postMessage, window.name, clipboard, drag-and-drop). A
    request-only scanner cannot deliver a payload there at all, so scoring it
    against them measures nothing. `--reach` selects which population is
    scored; the two are never merged into one unlabelled number.

Anything still untriaged carries `reach: "unknown"` and is likewise kept out
of the default denominator — "not yet classified" is not the same claim as
"reviewed and found unreachable", and neither is a scanner's fault.
"""

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Sequence, Set, Tuple
from urllib.parse import urljoin, urlparse

import requests

# Reach buckets scored by each --reach mode. Controls are excluded from every
# one of them; they are scored as false positives instead, in all modes.
REACH_MODES: Dict[str, Tuple[str, ...]] = {
    "server": ("server",),
    "client": ("client",),
    "all": ("server", "client", "unknown"),
}


def normalize_path(url: str) -> str:
    """Reduce a reported URL (absolute or relative) to a catalog path key."""
    path = urlparse(url).path or "/"
    if len(path) > 1 and path.endswith("/"):
        path = path[:-1]
    return path


@dataclass(frozen=True)
class Endpoint:
    """One entry of /map/json."""

    name: str
    url: str
    type: str
    method: str
    params: Tuple[str, ...]
    vuln_class: str
    reach: str
    delivery: Tuple[str, ...]
    sources: Tuple[str, ...]
    sinks: Tuple[str, ...]
    exploitable: bool
    note: Optional[str]

    @classmethod
    def from_json(cls, obj: Dict[str, Any]) -> "Endpoint":
        vuln = obj.get("vuln") or {}
        return cls(
            name=obj["name"],
            url=obj["url"],
            type=obj.get("type", ""),
            method=obj.get("method", "GET"),
            params=tuple(obj.get("params") or ()),
            vuln_class=vuln.get("class", "unclassified"),
            reach=vuln.get("reach", "unknown"),
            delivery=tuple(vuln.get("delivery") or ()),
            sources=tuple(vuln.get("sources") or ()),
            sinks=tuple(vuln.get("sinks") or ()),
            exploitable=bool(vuln.get("exploitable", True)),
            note=vuln.get("note"),
        )

    @property
    def path(self) -> str:
        return normalize_path(self.url)

    @property
    def is_control(self) -> bool:
        return not self.exploitable

    @property
    def path_prefix(self) -> Optional[str]:
        """Directory to match on for mazes that take their payload in the path.

        Those register a sample last segment (`:path` params, e.g.
        `/path/level1/a`), but a scanner reports the segment it actually sent,
        so an exact path compare would never line up.
        """
        if not any(p.startswith(":") for p in self.params):
            return None
        parent = self.path.rsplit("/", 1)[0]
        return parent or None


class EndpointIndex:
    """Resolves whatever a scanner reported back to a catalog endpoint."""

    def __init__(self, endpoints: Sequence[Endpoint]):
        self.endpoints = list(endpoints)
        self._by_path: Dict[str, Endpoint] = {}
        for ep in self.endpoints:
            self._by_path.setdefault(ep.path, ep)
        # Longest prefix first, so /path/level1 wins over a hypothetical /path.
        self._prefixes: List[Tuple[str, Endpoint]] = sorted(
            ((ep.path_prefix, ep) for ep in self.endpoints if ep.path_prefix),
            key=lambda pair: len(pair[0]),
            reverse=True,
        )

    def resolve(self, reported: str) -> Optional[Endpoint]:
        path = normalize_path(reported)
        hit = self._by_path.get(path)
        if hit is not None:
            return hit
        for prefix, ep in self._prefixes:
            if path == prefix or path.startswith(prefix + "/"):
                return ep
        return None


@dataclass
class ScannerResult:
    """Raw output of one scanner run: what it claimed, and how long it took."""

    name: str
    detections: Set[str] = field(default_factory=set)
    execution_time: float = 0.0
    skipped: bool = False
    skip_reason: str = ""


@dataclass
class Score:
    """A scanner's confusion matrix against one scored population."""

    scanner: ScannerResult
    population: List[Endpoint]
    tp: List[Endpoint]
    fn: List[Endpoint]
    fp_controls: List[Endpoint]
    fp_unmatched: List[str]
    unscored_hits: List[Endpoint]

    @property
    def fp(self) -> int:
        return len(self.fp_controls) + len(self.fp_unmatched)

    @property
    def precision(self) -> float:
        claimed = len(self.tp) + self.fp
        return len(self.tp) / claimed if claimed else 0.0

    @property
    def recall(self) -> float:
        return len(self.tp) / len(self.population) if self.population else 0.0

    @property
    def f1(self) -> float:
        p, r = self.precision, self.recall
        return 2 * p * r / (p + r) if (p + r) else 0.0


def breakdown(population: Sequence[Endpoint], detected: Set[str],
              key) -> Dict[str, Dict[str, Any]]:
    """detected/missed per key, against the corrected denominator."""
    rows: Dict[str, Dict[str, Any]] = {}
    for ep in population:
        row = rows.setdefault(key(ep), {"total": 0, "detected": 0, "missed": 0})
        row["total"] += 1
        if ep.name in detected:
            row["detected"] += 1
    for row in rows.values():
        row["missed"] = row["total"] - row["detected"]
        row["rate"] = row["detected"] / row["total"] * 100 if row["total"] else 0.0
    return rows


def sorted_breakdown(rows: Dict[str, Dict[str, Any]]) -> List[Tuple[str, Dict[str, Any]]]:
    """Worst first: most missed, then largest, then alphabetical."""
    return sorted(rows.items(), key=lambda kv: (-kv[1]["missed"], -kv[1]["total"], kv[0]))


# --------------------------------------------------------------------------
# Detection contract
# --------------------------------------------------------------------------


def parse_json_path(expr: str) -> List[Tuple[str, Optional[str]]]:
    """Compile a dotted extractor like `results[].matched-at` into steps.

    `[]` flattens one array level, so `[].url`, `results[].url` and
    `a.b[][].url` all work. Deliberately tiny: enough to pull URLs out of the
    JSON scanners already emit, without a jsonpath dependency.
    """
    steps: List[Tuple[str, Optional[str]]] = []
    for raw in expr.split("."):
        if not raw:
            continue
        key, arrays = raw, 0
        while key.endswith("[]"):
            key, arrays = key[:-2], arrays + 1
        if key:
            steps.append(("key", key))
        steps.extend([("each", None)] * arrays)
    return steps


def apply_json_path(doc: Any, steps: Sequence[Tuple[str, Optional[str]]]) -> List[Any]:
    values = [doc]
    for kind, key in steps:
        nxt: List[Any] = []
        for value in values:
            if kind == "key":
                if isinstance(value, dict) and key in value:
                    nxt.append(value[key])
            elif isinstance(value, list):
                nxt.extend(value)
        values = nxt
    return values


def json_documents(text: str) -> List[Any]:
    """Parse stdout as one JSON document, else as JSON Lines."""
    text = text.strip()
    if not text:
        return []
    try:
        return [json.loads(text)]
    except json.JSONDecodeError:
        pass
    docs = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            docs.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return docs


class DetectionContract:
    """How a scanner's output is turned into detections.

    The predecessor of this class was a heuristic — "exit code 0, *or* the
    word xss/vulnerable/detected/found appears anywhere in stdout" — which
    scored every scanner that merely ran successfully at 100%. A detection now
    has to be stated by the scanner and matched explicitly here. The exit code
    is only ever used to report that the run itself failed.
    """

    def __init__(self, regex: Optional[str], json_path: Optional[str],
                 stream: str = "stdout"):
        if bool(regex) == bool(json_path):
            raise ValueError(
                "a custom scanner needs exactly one of --detect-regex or "
                "--detect-json; exit code alone never marks a detection"
            )
        # MULTILINE so a line-oriented contract like '^FOUND (\S+)'
        # anchors per output line rather than only at the first byte.
        self.regex = re.compile(regex, re.MULTILINE) if regex else None
        self.json_path = json_path
        self.steps = parse_json_path(json_path) if json_path else None
        self.stream = stream

    def describe(self) -> str:
        what = f"--detect-regex {self.regex.pattern!r}" if self.regex \
            else f"--detect-json {self.json_path!r}"
        return f"{what} on {self.stream}"

    def _text(self, stdout: str, stderr: str) -> str:
        if self.stream == "stderr":
            return stderr
        if self.stream == "both":
            return stdout + "\n" + stderr
        return stdout

    def values(self, stdout: str, stderr: str) -> List[str]:
        """Every value the contract extracts — used as URLs in batch mode."""
        text = self._text(stdout, stderr)
        if self.regex is not None:
            return [m.group(1) if m.groups() else m.group(0)
                    for m in self.regex.finditer(text)]
        out: List[str] = []
        for doc in json_documents(text):
            for value in apply_json_path(doc, self.steps or []):
                if value is None or value is False:
                    continue
                out.append(value if isinstance(value, str) else json.dumps(value))
        return out

    def matched(self, stdout: str, stderr: str) -> bool:
        """Did the scanner claim a finding? — used in per-URL mode."""
        if self.regex is not None:
            return self.regex.search(self._text(stdout, stderr)) is not None
        return bool(self.values(stdout, stderr))


# --------------------------------------------------------------------------
# Benchmark
# --------------------------------------------------------------------------


class XSSMazeBenchmark:
    """Main benchmark orchestrator."""

    def __init__(self, target_url: str, reach_mode: str = "server",
                 verbose: bool = False):
        self.target_url = target_url.rstrip("/")
        self.reach_mode = reach_mode
        self.verbose = verbose
        self.endpoints: List[Endpoint] = []
        self.population: List[Endpoint] = []
        self.index = EndpointIndex([])

    def log(self, message: str, force: bool = False):
        if self.verbose or force:
            print(message)

    # -- catalog ----------------------------------------------------------

    def _map_json(self, **filters: str) -> List[Endpoint]:
        response = requests.get(f"{self.target_url}/map/json",
                                params=filters or None, timeout=30)
        response.raise_for_status()
        return [Endpoint.from_json(o) for o in response.json().get("endpoints", [])]

    def fetch_endpoints(self) -> bool:
        """Load the whole catalog, then let the server pick the population.

        /map/json accepts `?reach=` and `?exploitable=`, so which endpoints
        count is decided by the lab's own definitions rather than re-derived
        here. The full catalog is still needed to tell a false positive on a
        control apart from one on a path that is not a maze at all.
        """
        self.log(f"Fetching endpoints from {self.target_url}/map/json ...", force=True)
        try:
            self.endpoints = self._map_json()
            reaches = REACH_MODES[self.reach_mode]
            if len(reaches) == 1:
                self.population = self._map_json(exploitable="true", reach=reaches[0])
            else:
                self.population = self._map_json(exploitable="true")
        except requests.RequestException as e:
            print(f"Error fetching endpoints: {e}", file=sys.stderr)
            return False

        self.index = EndpointIndex(self.endpoints)
        self.log(f"Retrieved {len(self.endpoints)} endpoints; "
                 f"{len(self.population)} scored under --reach {self.reach_mode}",
                 force=True)
        return True

    @property
    def controls(self) -> List[Endpoint]:
        return [ep for ep in self.endpoints if ep.is_control]

    @property
    def scan_targets(self) -> List[Endpoint]:
        """URLs handed to the scanner: the population plus every control.

        Controls have to be probed, otherwise a false positive on one could
        never be observed and the precision column would be decorative.
        """
        seen = {ep.name for ep in self.population}
        return sorted(self.population + [ep for ep in self.controls
                                         if ep.name not in seen],
                      key=lambda ep: ep.name)

    def reach_census(self) -> Dict[str, int]:
        census: Dict[str, int] = {}
        for ep in self.endpoints:
            if ep.is_control:
                continue
            census[ep.reach] = census.get(ep.reach, 0) + 1
        return census

    def get_full_url(self, endpoint_url: str) -> str:
        if endpoint_url.startswith("http"):
            return endpoint_url
        return urljoin(self.target_url + "/", endpoint_url.lstrip("/"))

    # -- scanners ---------------------------------------------------------

    def run_nuclei_scanner(self) -> ScannerResult:
        """Run Nuclei against the scan targets and read its JSON findings."""
        self.log("\n=== Running Nuclei Scanner ===", force=True)
        start_time = time.time()
        detected: Set[str] = set()

        try:
            subprocess.run(["nuclei", "-version"], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log("Nuclei not found, skipping...", force=True)
            return ScannerResult("Nuclei", detected, 0.0, skipped=True,
                                 skip_reason="nuclei not found in PATH")

        with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
            for ep in self.scan_targets:
                f.write(self.get_full_url(ep.url) + "\n")
            url_file = f.name

        try:
            self.log("Running nuclei (this may take a few minutes)...")
            result = subprocess.run([
                "nuclei", "-l", url_file,
                "-t", "cves/", "-t", "vulnerabilities/",
                "-tags", "xss", "-json", "-silent",
            ], capture_output=True, text=True, timeout=900)

            for line in result.stdout.splitlines():
                if not line.strip():
                    continue
                try:
                    finding = json.loads(line)
                except json.JSONDecodeError:
                    continue
                matched_url = finding.get("matched-at", "")
                if matched_url:
                    detected.add(matched_url)
        except subprocess.TimeoutExpired:
            self.log("Nuclei scan timed out", force=True)
        except OSError as e:
            self.log(f"Nuclei scan error: {e}", force=True)
        finally:
            os.unlink(url_file)

        elapsed = time.time() - start_time
        self.log(f"Nuclei reported {len(detected)} findings in {elapsed:.1f}s")
        return ScannerResult("Nuclei", detected, elapsed)

    def run_custom_scanner(self, name: str, template: str,
                           contract: DetectionContract,
                           timeout: Optional[int] = None) -> ScannerResult:
        """Run a custom scanner under an explicit detection contract.

        `{URL}` in the template runs the scanner once per endpoint, and the
        contract decides whether *that* endpoint was flagged. `{URLFILE}` (or
        no placeholder at all, in which case the list arrives on stdin) runs it
        once over the whole list, and the contract extracts the URLs it
        flagged. Either way a detection needs a real match.
        """
        self.log(f"\n=== Running {name} Scanner ===", force=True)
        self.log(f"Detection contract: {contract.describe()}", force=True)
        start_time = time.time()

        argv = shlex.split(template)
        targets = self.scan_targets
        if any("{URL}" in part for part in argv):
            detected = self._run_per_url(name, argv, contract, targets,
                                         timeout if timeout is not None else 30)
        else:
            detected = self._run_batch(name, argv, contract, targets,
                                       timeout if timeout is not None else 600)

        elapsed = time.time() - start_time
        self.log(f"{name} reported {len(detected)} findings in {elapsed:.1f}s",
                 force=True)
        return ScannerResult(name, detected, elapsed)

    def _run_per_url(self, name: str, argv: List[str],
                     contract: DetectionContract, targets: List[Endpoint],
                     timeout: int) -> Set[str]:
        detected: Set[str] = set()
        for i, ep in enumerate(targets, 1):
            full_url = self.get_full_url(ep.url)
            cmd = [part.replace("{URL}", full_url) for part in argv]
            try:
                proc = subprocess.run(cmd, capture_output=True, text=True,
                                      timeout=timeout)
            except subprocess.TimeoutExpired:
                self.log(f"  timeout scanning {full_url}")
                continue
            except OSError as e:
                print(f"Error running {name}: {e}", file=sys.stderr)
                break
            if contract.matched(proc.stdout, proc.stderr):
                detected.add(ep.url)
            if self.verbose and i % 50 == 0:
                self.log(f"  {i}/{len(targets)} scanned, {len(detected)} flagged")
        return detected

    def _run_batch(self, name: str, argv: List[str],
                   contract: DetectionContract, targets: List[Endpoint],
                   timeout: int) -> Set[str]:
        urls = "\n".join(self.get_full_url(ep.url) for ep in targets) + "\n"
        url_file = None
        if any("{URLFILE}" in part for part in argv):
            with tempfile.NamedTemporaryFile(mode="w", suffix=".txt",
                                             delete=False) as f:
                f.write(urls)
                url_file = f.name
            argv = [part.replace("{URLFILE}", url_file) for part in argv]
            stdin = None
        else:
            stdin = urls

        try:
            proc = subprocess.run(argv, input=stdin, capture_output=True,
                                  text=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            self.log(f"{name} timed out after {timeout}s", force=True)
            return set()
        except OSError as e:
            print(f"Error running {name}: {e}", file=sys.stderr)
            return set()
        finally:
            if url_file:
                os.unlink(url_file)

        if proc.returncode != 0:
            self.log(f"{name} exited {proc.returncode} "
                     f"(scoring its output anyway)", force=True)
        return set(contract.values(proc.stdout, proc.stderr))

    # -- scoring ----------------------------------------------------------

    def score(self, result: ScannerResult) -> Score:
        """TP / FN / FP against the population, controls held out as FP."""
        in_scope = {ep.name for ep in self.population}
        tp: Dict[str, Endpoint] = {}
        controls: Dict[str, Endpoint] = {}
        unscored: Dict[str, Endpoint] = {}
        unmatched: Set[str] = set()

        for reported in result.detections:
            ep = self.index.resolve(reported)
            if ep is None:
                # Not a maze at all: the scanner invented a finding.
                unmatched.add(normalize_path(reported))
            elif ep.is_control:
                controls[ep.name] = ep
            elif ep.name in in_scope:
                tp[ep.name] = ep
            else:
                # A real bug, but outside the population this mode scores.
                # Neither a hit nor a miss; reported separately.
                unscored[ep.name] = ep

        fn = [ep for ep in self.population if ep.name not in tp]
        return Score(
            scanner=result,
            population=list(self.population),
            tp=sorted(tp.values(), key=lambda ep: ep.name),
            fn=fn,
            fp_controls=sorted(controls.values(), key=lambda ep: ep.name),
            fp_unmatched=sorted(unmatched),
            unscored_hits=sorted(unscored.values(), key=lambda ep: ep.name),
        )

    # -- reporting --------------------------------------------------------

    def _header_lines(self) -> List[str]:
        census = self.reach_census()
        reaches = REACH_MODES[self.reach_mode]
        excluded = [f"{n} {reach}-reach" for reach, n in sorted(census.items())
                    if reach not in reaches]
        lines = [
            f"Target:            {self.target_url}",
            f"Catalog:           {len(self.endpoints)} endpoints, "
            f"{len(set(ep.type for ep in self.endpoints))} categories",
            f"Controls:          {len(self.controls)} with exploitable=false "
            f"(a detection there is a FALSE POSITIVE, never a miss)",
            "Exploitable reach: " + ", ".join(f"{n} {reach}" for reach, n
                                              in sorted(census.items())),
            "",
            f"Scoring mode:      --reach {self.reach_mode}",
            f"Scored population: {len(self.population)} exploitable endpoints "
            f"(reach: {', '.join(reaches)})",
        ]
        if excluded:
            lines.append(f"Not scored:        {', '.join(excluded)}, plus "
                         f"{len(self.controls)} controls — hits there are "
                         f"listed separately, never as TP or FN")
        return lines

    def generate_scorecard(self, scores: List[Score], breakdown_limit: int = 20):
        print("\n" + "=" * 78)
        print("XSSMaze Scanner Benchmark Results")
        print("=" * 78 + "\n")
        for line in self._header_lines():
            print(line)
        print()

        if not scores:
            print("No scanner results available.")
            return

        print(f"{'Scanner':<20} {'TP':>5} {'FN':>5} {'FP':>5} "
              f"{'Precision':>10} {'Recall':>9} {'F1':>7} {'Time':>9}")
        print("-" * 78)
        for score in scores:
            if score.scanner.skipped:
                print(f"{score.scanner.name:<20} {'— skipped: ' + score.scanner.skip_reason}")
                continue
            print(f"{score.scanner.name:<20} {len(score.tp):>5} {len(score.fn):>5} "
                  f"{score.fp:>5} {score.precision * 100:>9.1f}% "
                  f"{score.recall * 100:>8.1f}% {score.f1:>7.3f} "
                  f"{score.scanner.execution_time:>8.1f}s")

        for score in scores:
            if score.scanner.skipped:
                continue
            self._print_detail(score, breakdown_limit)

    def _print_detail(self, score: Score, breakdown_limit: int):
        detected = {ep.name for ep in score.tp}
        total = len(score.population)
        print(f"\n\n--- {score.scanner.name} ---\n")
        print(f"  Reported findings:  {len(score.scanner.detections)}")
        print(f"  True positives:     {len(score.tp)}/{total}")
        print(f"  False negatives:    {len(score.fn)}/{total}")
        print(f"  False positives:    {score.fp} "
              f"({len(score.fp_controls)} on controls, "
              f"{len(score.fp_unmatched)} on non-maze paths)")
        if score.unscored_hits:
            print(f"  Unscored hits:      {len(score.unscored_hits)} "
                  f"(real bugs outside --reach {self.reach_mode})")
        print(f"  Precision:          {score.precision * 100:.1f}%")
        print(f"  Recall:             {score.recall * 100:.1f}%")
        print(f"  F1:                 {score.f1:.3f}")

        if self.reach_mode == "all":
            self._print_table("By reach", breakdown(score.population, detected,
                                                    lambda ep: ep.reach), 0)
        self._print_table("By vulnerability class",
                          breakdown(score.population, detected,
                                    lambda ep: ep.vuln_class), 0)
        self._print_table("By category (worst first)",
                          breakdown(score.population, detected,
                                    lambda ep: ep.type), breakdown_limit)

        if score.fp_controls:
            print("\n  False positives on controls "
                  "(exploitable=false — reporting nothing here is correct):")
            for ep in score.fp_controls:
                print(f"    ✗ {ep.name}  {ep.url}")
        if score.fp_unmatched:
            print("\n  False positives on paths that are not mazes:")
            for path in score.fp_unmatched:
                print(f"    ✗ {path}")
        if score.unscored_hits:
            print("\n  Hits outside the scored population "
                  "(counted as neither TP nor FP):")
            for ep in score.unscored_hits:
                print(f"    · {ep.name}  [reach: {ep.reach}]  {ep.url}")
        if self.verbose and score.tp:
            print("\n  Detected:")
            for ep in score.tp:
                print(f"    ✓ {ep.name}  {ep.url}")

    def _print_table(self, title: str, rows: Dict[str, Dict[str, Any]],
                     limit: int):
        ordered = sorted_breakdown(rows)
        shown = ordered[:limit] if limit else ordered
        print(f"\n  {title}:")
        width = max((len(k) for k, _ in shown), default=4)
        for key, row in shown:
            print(f"    {key:<{width}}  {row['detected']:>4} detected  "
                  f"{row['missed']:>4} missed  of {row['total']:>4}  "
                  f"({row['rate']:.1f}%)")
        if len(ordered) > len(shown):
            print(f"    ... {len(ordered) - len(shown)} more "
                  f"(use --breakdown-limit 0, -o or --json for the full table)")

    def generate_markdown_report(self, scores: List[Score], output_file: str):
        with open(output_file, "w") as f:
            f.write("# XSSMaze Scanner Benchmark Report\n\n")
            for line in self._header_lines():
                if line:
                    label, _, value = line.partition(":")
                    f.write(f"**{label.strip()}:** {value.strip()}  \n")
            f.write("\n> Endpoints with `exploitable: false` are deliberate true "
                    "negatives and are excluded from the denominator; a detection "
                    "on one is a false positive. Endpoints outside the scored "
                    "`reach` are excluded too — a request-only scanner cannot "
                    "deliver a payload to a browser-only channel.\n\n")

            f.write("## Summary\n\n")
            f.write("| Scanner | TP | FN | FP | Precision | Recall | F1 | Time |\n")
            f.write("|---------|----|----|----|-----------|--------|----|------|\n")
            for score in scores:
                if score.scanner.skipped:
                    f.write(f"| {score.scanner.name} | — | — | — | — | — | — | "
                            f"skipped: {score.scanner.skip_reason} |\n")
                    continue
                f.write(f"| {score.scanner.name} | {len(score.tp)} | {len(score.fn)} "
                        f"| {score.fp} | {score.precision * 100:.1f}% "
                        f"| {score.recall * 100:.1f}% | {score.f1:.3f} "
                        f"| {score.scanner.execution_time:.1f}s |\n")

            f.write("\n## Detailed Results\n\n")
            for score in scores:
                f.write(f"### {score.scanner.name}\n\n")
                if score.scanner.skipped:
                    f.write(f"Skipped: {score.scanner.skip_reason}\n\n")
                    continue
                total = len(score.population)
                detected = {ep.name for ep in score.tp}
                f.write(f"- **Reported findings:** {len(score.scanner.detections)}\n")
                f.write(f"- **True positives:** {len(score.tp)}/{total}\n")
                f.write(f"- **False negatives:** {len(score.fn)}/{total}\n")
                f.write(f"- **False positives:** {score.fp} "
                        f"({len(score.fp_controls)} on controls, "
                        f"{len(score.fp_unmatched)} on non-maze paths)\n")
                if score.unscored_hits:
                    f.write(f"- **Unscored hits:** {len(score.unscored_hits)} "
                            f"(real bugs outside `--reach {self.reach_mode}`)\n")
                f.write(f"- **Precision / Recall / F1:** {score.precision * 100:.1f}% / "
                        f"{score.recall * 100:.1f}% / {score.f1:.3f}\n\n")

                if self.reach_mode == "all":
                    self._write_table(f, "By Reach",
                                      breakdown(score.population, detected,
                                                lambda ep: ep.reach))
                self._write_table(f, "By Vulnerability Class",
                                  breakdown(score.population, detected,
                                            lambda ep: ep.vuln_class))
                self._write_table(f, "By Category",
                                  breakdown(score.population, detected,
                                            lambda ep: ep.type))

                if score.fp_controls or score.fp_unmatched:
                    f.write("**False Positives:**\n\n")
                    for ep in score.fp_controls:
                        f.write(f"- `{ep.name}` (`{ep.url}`) — control, "
                                f"`exploitable: false`\n")
                    for path in score.fp_unmatched:
                        f.write(f"- `{path}` — not a registered maze\n")
                    f.write("\n")
                if score.unscored_hits:
                    f.write("**Hits Outside the Scored Population:**\n\n")
                    for ep in score.unscored_hits:
                        f.write(f"- `{ep.name}` (`{ep.url}`) — reach `{ep.reach}`\n")
                    f.write("\n")

        print(f"\nMarkdown report saved to: {output_file}")

    @staticmethod
    def _write_table(f, title: str, rows: Dict[str, Dict[str, Any]]):
        f.write(f"**{title}:**\n\n")
        f.write("| Key | Detected | Missed | Total | Rate |\n")
        f.write("|-----|----------|--------|-------|------|\n")
        for key, row in sorted_breakdown(rows):
            f.write(f"| `{key}` | {row['detected']} | {row['missed']} "
                    f"| {row['total']} | {row['rate']:.1f}% |\n")
        f.write("\n")

    def generate_json_report(self, scores: List[Score], output_file: str):
        """Machine-readable scorecard, so CI can diff two runs."""
        report = {
            "target": self.target_url,
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "reach_mode": self.reach_mode,
            "catalog": {
                "total": len(self.endpoints),
                "controls": len(self.controls),
                "exploitable_by_reach": self.reach_census(),
                "scored_population": len(self.population),
                "categories": len(set(ep.type for ep in self.endpoints)),
            },
            "scanners": [],
        }
        for score in scores:
            entry: Dict[str, Any] = {
                "name": score.scanner.name,
                "skipped": score.scanner.skipped,
                "execution_time": round(score.scanner.execution_time, 3),
            }
            if score.scanner.skipped:
                entry["skip_reason"] = score.scanner.skip_reason
                report["scanners"].append(entry)
                continue
            detected = {ep.name for ep in score.tp}
            entry.update({
                "reported_findings": len(score.scanner.detections),
                "population": len(score.population),
                "true_positives": len(score.tp),
                "false_negatives": len(score.fn),
                "false_positives": score.fp,
                "false_positives_on_controls": len(score.fp_controls),
                "false_positives_unmatched": len(score.fp_unmatched),
                "unscored_hits": len(score.unscored_hits),
                "precision": round(score.precision, 6),
                "recall": round(score.recall, 6),
                "f1": round(score.f1, 6),
                "by_reach": breakdown(score.population, detected,
                                      lambda ep: ep.reach),
                "by_class": breakdown(score.population, detected,
                                      lambda ep: ep.vuln_class),
                "by_type": breakdown(score.population, detected,
                                     lambda ep: ep.type),
                "detected": [ep.name for ep in score.tp],
                "missed": [ep.name for ep in score.fn],
                "detected_controls": [ep.name for ep in score.fp_controls],
                "detected_non_mazes": list(score.fp_unmatched),
                "detected_out_of_scope": [
                    {"name": ep.name, "reach": ep.reach} for ep in score.unscored_hits
                ],
            })
            report["scanners"].append(entry)

        with open(output_file, "w") as f:
            json.dump(report, f, indent=2, sort_keys=False)
            f.write("\n")
        print(f"JSON report saved to: {output_file}")


EPILOG = """
Examples:
  # Score a scanner against the server-reachable population (the default)
  python3 benchmark.py http://localhost:3000 --scanner nuclei

  # Custom scanner, one invocation per URL, regex detection contract
  python3 benchmark.py http://localhost:3000 --scanner none \\
    --custom-scanner "mytool --url {URL}" --custom-scanner-name MyTool \\
    --detect-regex '"severity":\\s*"(?:high|critical)"'

  # Custom scanner, one invocation over the whole list, JSON extractor
  python3 benchmark.py http://localhost:3000 --scanner none \\
    --custom-scanner "mytool -l {URLFILE} -json" \\
    --detect-json 'results[].url'

  # Include client-only endpoints (browser-driven scanners) and save both reports
  python3 benchmark.py http://localhost:3000 --reach all -o report.md --json run.json

Detection contract:
  A custom scanner MUST be given --detect-regex or --detect-json. A zero exit
  code never marks a detection; the old heuristic that did scored every
  well-behaved scanner at 100%.

Scoring:
  Endpoints with vuln.exploitable == false are controls: they are excluded from
  the denominator, and a detection on one is a false positive. --reach selects
  which reach bucket is scored; endpoints outside it are reported separately
  and counted as neither a hit nor a miss.
"""


def main():
    parser = argparse.ArgumentParser(
        description="Benchmark XSS scanners against XSSMaze",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=EPILOG,
    )
    parser.add_argument("target_url", help="Target URL of running XSSMaze instance")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose output")
    parser.add_argument("-o", "--output", metavar="FILE",
                        help="Write the markdown report to FILE")
    parser.add_argument("--json", metavar="FILE", dest="json_output",
                        help="Write the machine-readable scorecard to FILE")
    parser.add_argument("--reach", choices=sorted(REACH_MODES), default="server",
                        help="Which population to score: 'server' (default; the "
                             "endpoints a request-only scanner can actually "
                             "reach), 'client' (browser-only channels), or 'all' "
                             "(both, broken out by reach)")
    parser.add_argument("--breakdown-limit", type=int, default=20, metavar="N",
                        help="Rows in the per-category console table; 0 for all "
                             "(default: 20). Markdown and JSON always get all.")
    parser.add_argument("--scanner", choices=["nuclei", "all", "none"],
                        default="all",
                        help="Built-in scanner to run (default: all available)")
    parser.add_argument("--custom-scanner", metavar="COMMAND",
                        help="Custom scanner command. {URL} runs it once per "
                             "endpoint; {URLFILE} (or no placeholder, list on "
                             "stdin) runs it once over the whole list.")
    parser.add_argument("--custom-scanner-name", metavar="NAME", default="Custom",
                        help="Name for the custom scanner in the report")
    parser.add_argument("--detect-regex", metavar="REGEX",
                        help="Detection contract: a finding is recorded only "
                             "where this matches. In batch mode capture group 1 "
                             "(or the whole match) is the flagged URL.")
    parser.add_argument("--detect-json", metavar="PATH",
                        help="Detection contract for structured output: a dotted "
                             "extractor such as 'results[].url' applied to the "
                             "scanner's JSON or JSON Lines output.")
    parser.add_argument("--detect-stream", choices=["stdout", "stderr", "both"],
                        default="stdout",
                        help="Stream the detection contract reads (default: stdout)")
    parser.add_argument("--scanner-timeout", type=int, metavar="SECONDS",
                        help="Timeout per custom scanner invocation "
                             "(default: 30 per-URL, 600 batch)")

    args = parser.parse_args()

    contract = None
    if args.custom_scanner:
        try:
            contract = DetectionContract(args.detect_regex, args.detect_json,
                                         args.detect_stream)
        except ValueError as e:
            parser.error(str(e))
    elif args.detect_regex or args.detect_json:
        parser.error("--detect-regex/--detect-json only apply to --custom-scanner")

    benchmark = XSSMazeBenchmark(args.target_url, reach_mode=args.reach,
                                 verbose=args.verbose)
    if not benchmark.fetch_endpoints():
        return 1
    if not benchmark.endpoints:
        print("No endpoints found. Is XSSMaze running?", file=sys.stderr)
        return 1
    if not benchmark.population:
        print(f"No endpoints match --reach {args.reach}; nothing to score.",
              file=sys.stderr)
        return 1

    results: List[ScannerResult] = []
    if args.scanner in ("all", "nuclei"):
        results.append(benchmark.run_nuclei_scanner())
    if contract is not None:
        results.append(benchmark.run_custom_scanner(
            args.custom_scanner_name, args.custom_scanner, contract,
            args.scanner_timeout))

    if not results:
        print("No scanners selected. Pass --scanner nuclei or --custom-scanner.",
              file=sys.stderr)
        return 1

    scores = [benchmark.score(r) for r in results]
    benchmark.generate_scorecard(scores, args.breakdown_limit)
    if args.output:
        benchmark.generate_markdown_report(scores, args.output)
    if args.json_output:
        benchmark.generate_json_report(scores, args.json_output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
