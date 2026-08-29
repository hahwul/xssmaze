# XSSMaze Benchmark Scripts

Tools for scoring an XSS scanner against a running XSSMaze instance.

## Files

- **`benchmark.py`**: the scorecard
- **`benchmark.sh`**: convenience wrapper (dependency check, then pass-through)

## Quick Start

```bash
# Start XSSMaze (in one terminal)
cd ..
./bin/xssmaze

# Score a scanner (in another terminal)
cd scripts
./benchmark.sh http://localhost:3000 --scanner nuclei
```

## Requirements

- Python 3.x
- `requests` (installed by `benchmark.sh` if missing)
- Optional: the scanner under test, e.g. [Nuclei](https://github.com/projectdiscovery/nuclei)

## What gets scored, and why

Every number comes from the structured vulnerability metadata XSSMaze already
serves on `/map/json` — `vuln.class`, `vuln.reach`, `vuln.exploitable`. **The
denominator is deliberately smaller than the catalog.** Two populations are
held out, and both exclusions are on purpose:

### `exploitable: false` — controls

Six endpoints (the whole `xsleak` category plus `dom-level10`) are marked
`vuln.class: non-xss-control`, `exploitable: false`. They are not XSS bugs;
they are true negatives that exist to catch scanners which cry wolf.

- They are **removed from the denominator**. A scanner that reports nothing
  there is behaving correctly and must not be punished for it.
- A detection on one is a **false positive**, in every `--reach` mode.
- They are still handed to the scanner to probe, otherwise a false positive on
  a control could never be observed and the precision column would be
  decorative.

### `reach: "client"` — browser-only delivery

Twenty endpoints take their payload from a channel that only exists inside a
browser: `fragment`, `postmessage`, `window-name`, clipboard, drag-and-drop.
A request-only scanner cannot deliver a payload to them at all — the fragment
is never even sent to the server. Scoring one against them measures nothing,
so `--reach` picks the population explicitly and the report always labels
which one it used.

### `reach: "unknown"` — untriaged

Most of the catalog has not been triaged yet (`vuln.class: unclassified`,
`reach: "unknown"`). "Not yet classified" is a different claim from "reviewed
and found reachable", so untriaged endpoints stay out of the default
denominator too. `--reach all` includes them, broken out on their own row so
they are never silently folded into the server-reachable score.

The header of every report prints the census, so the size of each population
is visible before any rate is read:

```
Catalog:           1064 endpoints, 175 categories
Controls:          6 with exploitable=false (a detection there is a FALSE POSITIVE, never a miss)
Exploitable reach: 20 client, 200 server, 838 unknown

Scoring mode:      --reach server
Scored population: 200 exploitable endpoints (reach: server)
Not scored:        20 client-reach, 838 unknown-reach, plus 6 controls — hits there are listed separately, never as TP or FN
```

### The metrics

| Term | Definition |
|------|------------|
| **TP** | detection resolving to an endpoint in the scored population |
| **FN** | scored endpoint with no detection (`population − TP`) |
| **FP** | detection on an `exploitable: false` control, **or** on a path that is not a registered maze |
| **Precision** | `TP / (TP + FP)` |
| **Recall** | `TP / population` |
| **F1** | harmonic mean of the two |

A detection on a real bug that sits *outside* the scored population — a
client-only endpoint under `--reach server`, say — is neither. It is listed as
an **unscored hit**: the finding is genuine, it just does not belong to the
population this run measures.

Detections are matched to endpoints by normalized path (trailing slash
insensitive, host and query ignored). Mazes that take their payload in the
path (`:path` params, e.g. `/path/level1/a`) match on their parent directory,
because a scanner reports the segment it actually sent.

## Reach modes

```bash
--reach server   # default: the 200 endpoints a request-only scanner can reach
--reach client   # the 20 browser-only endpoints, for a browser-driven scanner
--reach all      # every exploitable endpoint, with a per-reach breakdown
```

`--reach all` still reports server / client / unknown as separate rows. The
two populations are never merged into one unlabelled number.

## Detection contract

**A custom scanner must declare how it reports a finding.** Exactly one of
`--detect-regex` or `--detect-json` is required, and a zero exit code never
marks a detection on its own.

This replaces the previous heuristic — *"exit code 0, or the words
xss/vulnerable/detected/found appear anywhere in stdout"* — which scored every
scanner that merely ran successfully at 100%, making every custom-scanner
number the tool produced meaningless.

| Flag | Meaning |
|------|---------|
| `--detect-regex REGEX` | a finding is recorded only where this matches |
| `--detect-json PATH` | dotted extractor over the scanner's JSON / JSON Lines output, e.g. `results[].url`, `[].matched-at` |
| `--detect-stream` | which stream the contract reads: `stdout` (default), `stderr`, `both` |

### Per-URL mode — `{URL}`

The scanner runs once per endpoint. The contract decides whether *that*
endpoint was flagged: the regex matching anywhere, or the extractor yielding
at least one truthy value.

```bash
python3 benchmark.py http://localhost:3000 --scanner none \
  --custom-scanner "mytool --url {URL}" --custom-scanner-name MyTool \
  --detect-regex 'VULNERABLE'
```

### Batch mode — `{URLFILE}`, or no placeholder

The scanner runs once over the whole target list, given a file of URLs via
`{URLFILE}` or the list on stdin. Detections are the URLs read *out of its
output*: the extractor's values, or capture group 1 of the regex (the whole
match if it has no groups).

```bash
# structured output
python3 benchmark.py http://localhost:3000 --scanner none \
  --custom-scanner "mytool -l {URLFILE} -json" \
  --detect-json 'results[].url'

# line-oriented output like "FOUND http://host/path"
python3 benchmark.py http://localhost:3000 --scanner none \
  --custom-scanner "mytool -l {URLFILE}" \
  --detect-regex '^FOUND (\S+)'
```

`--detect-json` accepts one JSON document or JSON Lines; `[]` flattens an
array level, so `[].url`, `results[].url` and `a.b[][].url` all work.
Unparseable lines are skipped rather than aborting the run.

The exit code never marks a detection either way. In batch mode a non-zero
exit is reported as a warning and the output is scored anyway — a crash after
some findings should not silently become a clean sheet. In per-URL mode it is
ignored outright.

### Timeouts

`--scanner-timeout SECONDS` applies per invocation: 30s by default in per-URL
mode, 600s in batch mode.

## Output

### Console

Summary table, then per-scanner detail: the confusion counts, precision /
recall / F1, breakdowns by `vuln.class` and by category against the corrected
denominator, and the full list of false positives and unscored hits.

```
Scanner                 TP    FN    FP  Precision    Recall      F1      Time
------------------------------------------------------------------------------
FakeBatch                8   192     3      72.7%      4.0%   0.076      0.0s
```

The per-category table is capped at `--breakdown-limit` rows (default 20,
worst first; `0` for all). Markdown and JSON always contain every row.

### Markdown — `-o FILE`

The same corrected numbers as tables, plus the named lists.

### JSON — `--json FILE`

Machine-readable, so two runs can be diffed in CI:

```json
{
  "target": "http://localhost:3000",
  "reach_mode": "server",
  "catalog": {
    "total": 1064, "controls": 6, "scored_population": 200,
    "exploitable_by_reach": {"server": 200, "client": 20, "unknown": 838}
  },
  "scanners": [{
    "name": "MyTool", "reported_findings": 13, "population": 200,
    "true_positives": 8, "false_negatives": 192, "false_positives": 3,
    "false_positives_on_controls": 2, "false_positives_unmatched": 1,
    "unscored_hits": 2,
    "precision": 0.727273, "recall": 0.04, "f1": 0.075829,
    "by_reach": {}, "by_class": {}, "by_type": {},
    "detected": [], "missed": [],
    "detected_controls": [], "detected_non_mazes": [],
    "detected_out_of_scope": []
  }]
}
```

```bash
# regression gate: fail the build if recall drops
python3 benchmark.py http://localhost:3000 --scanner nuclei --json run.json
python3 -c "import json,sys; r=json.load(open('run.json'))['scanners'][0]; \
  sys.exit(r['recall'] < 0.20 or r['false_positives'] > 0)"
```

## Adding Scanner Support

### Option 1: `--custom-scanner`

Any tool that can be told about a URL and print what it found — see the
detection contract above. Nothing needs to change in `benchmark.py`.

### Option 2: extend `benchmark.py`

Add a method that returns a `ScannerResult`. Only the raw detections and the
elapsed time are its job; scoring is done centrally, so a new scanner
automatically gets the same denominator.

```python
def run_my_scanner(self) -> ScannerResult:
    """Run My Scanner against the scan targets."""
    start_time = time.time()
    detected: Set[str] = set()

    for ep in self.scan_targets:      # population + controls
        full_url = self.get_full_url(ep.url)
        # ... run the scanner; add the URL it flagged, not the one you sent
        # detected.add(reported_url)

    return ScannerResult("My Scanner", detected, time.time() - start_time)
```

Detections may be full URLs or bare paths; `EndpointIndex.resolve` normalizes
them. Call the method in `main()` and pass the result through
`benchmark.score()` with the others.

## Troubleshooting

### "requests module not found"

```bash
pip3 install requests
# or, on a PEP 668 / externally-managed Python:
python3 -m venv .venv && .venv/bin/pip install requests
.venv/bin/python benchmark.py http://localhost:3000
```

### "a custom scanner needs exactly one of --detect-regex or --detect-json"

By design. See [Detection contract](#detection-contract) — the tool refuses to
guess what counts as a finding.

### "nuclei: command not found"

Nuclei is skipped with a note in the report rather than failing the run. Use
`--scanner none` to skip it deliberately.

### "Connection refused"

```bash
curl http://localhost:3000/health
```

### Every rate looks low

Check the header first. Under `--reach server` the denominator is the ~200
server-reachable endpoints, not the whole catalog; a scanner finding 8 of them
is at 4% recall, not 0.8%. If the "unscored hits" list is long, the scanner is
finding real bugs in a population this mode does not score — try `--reach all`.

## Notes

- The catalog comes from `/map/json`; the scored population comes from the same
  endpoint's server-side filters (`?exploitable=true&reach=…`), so which
  endpoints count is decided by the lab's own definitions rather than
  re-derived here.
- The full catalog is still fetched, because telling a false positive on a
  control apart from one on a path that is not a maze needs all of it.
