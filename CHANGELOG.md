# Changelog

## Unreleased

- **`modern-bypass-level19` works again.** Its inline script never parsed:
  `/https://xssmaze.com/.test(...)` tokenises as the regex `/https:/` followed by a `//` line
  comment, leaving the `if (` unclosed, so the whole `<script>` was a SyntaxError, the
  `message` listener was never registered and the `eval` sink was unreachable. That is a typo,
  not a filter. The slashes are escaped, the level is a real postMessage → `eval` DOM flow
  again, and its deliberately unanchored origin RegExp still accepts
  `https://xssmaze.com.attacker.com` — verified end to end in headless Chrome via the
  `/beacon` oracle (matching origin fires, unrelated origin does not)
- **The lab stopped 500ing on a bare request.** 768 of 1031 GET mazes answered HTTP 500 to a
  path with no query string, because `env.params.query["x"]` raises `KeyError` when the
  parameter is absent. That is what a crawler saw first: `/sitemap.xml` publishes paths with
  the query string stripped, so 158 of its first 200 URLs were 500s, and any scanner fuzzing
  one parameter at a time crashed the levels that read a sibling. All 796 non-optional reads
  now default, behaviour with the parameter present is byte-identical, and the smoke spec
  gained the two shapes that missed this — a bare path, and each parameter sent with no
  siblings (#53, #54, #55, #56)
- **Every endpoint is classified.** `unclassified` went 838 -> 0 and `reach: "unknown"` with
  it, so `/map/json?reach=server` now returns the 1040 endpoints a request-only scanner can
  actually reach instead of the 206 it used to admit to. 28 endpoints are marked
  `exploitable: false` after review — CSP levels whose policy blocks the page's own inline
  script, open redirects, `application/json` bodies no browser sniffs — each verified in
  headless Chrome rather than argued from the served HTML (#47, #48, #49, #50)
- **Answer key served.** `solutions/` was 1049 ground-truth payloads that nothing referenced
  and `.dockerignore` excluded; it is now embedded at compile time and served as
  `/solutions.json`, `/solutions/<category>` and `/map/json?with=solutions`. A spec asserts
  catalog parity in both directions so it cannot drift again (#46)
- **Execution oracle.** `/beacon/<token>` records that a payload *ran* and `/beacon/log`
  reports it with the `Referer` that fired it, so a benchmark can tell execution from
  reflection and score the DOM flows whose payload never reaches the server response (#44)
- **Scorecard measures the right thing.** `scripts/benchmark.py` scored controls and
  client-only endpoints as misses and had no false-positive metric at all; it now reports
  TP/FN/FP with precision, recall and F1, excludes `exploitable: false` from the denominator
  and counts a detection there as a false positive, and picks its population with `--reach`.
  A custom scanner now needs an explicit `--detect-regex`/`--detect-json` contract — the old
  code marked an endpoint detected whenever the tool merely exited 0, so any well-behaved
  scanner scored 100% (#45)
- **Cookie reflections stopped 500ing.** `respheader-level4`, `rsplit-level4` and
  `realworld-input-level6` raised `IO::Error` on the exact payloads they exist to reflect,
  because `HTTP::Cookie` rejects the bytes RFC 6265 forbids — `rsplit-level4` is a response
  splitting level that died on the splitting characters. New `Xssmaze.cookie_value` keeps the
  reflection and drops the crash, and a smoke spec now walks the whole catalog so a 5xx
  cannot ship again (#43)
- **Stored mazes are bounded and resettable.** State grew without limit and never cleared, so
  a second scanner run read the first run's payloads back out as its own finding. Collections
  keep their most recent entries and `/reset` clears them between runs (#42)
- Fixed the `params:` lists that named a parameter the handler never reads, which had been
  telling a scanner reading `/map/json` to fuzz the wrong field — `rsplit-level4` advertised
  `query` while its sink is `pref`, `sink-level8` advertised `query` while only `callback` is
  read. 26 endpoints declared a parameter their own catalog URL contradicted; that is now 0
  (the 3 still flagged by that check are `multipart-*`, where `params` correctly names a
  header or body field and only the vestigial `?query=a` in the URL differs)

## v0.4.0

- Kemal 1.13.0, Crystal floor `>= 1.12.0`. Kemal now rejects a WebSocket without an `Origin`, so `/domsource/level7/echo` 403'd wscat, fuzzers and raw curl upgrades — `Server.start!` opts back into allow-all, pinned by a spec (#41)
- New `querymethod` category: five HTTP QUERY (RFC 10008) levels — form body, JSON body, attribute breakout, script string, and a method confusion level whose GET branch is safe (#41)
- `/map/openapi` emits non-standard methods under `x-additional-operations`; the index filter chip reads POST/QUERY (#41)

## v0.3.0

- CLI: XSSMaze parses its own ARGV — hand-rendered help, `-q`, `--no-banner`, `--no-color`, `-v`; a spiral banner that reports the real URL and catalog size, and one aligned request log line per request. `NO_COLOR`, `TERM=dumb` and non-TTY output honoured (#40)
- Web: the index redesigned on the "ember" palette with dark mode, a favicon, and WCAG AA contrast; rows render the vulnerability class, client-only reach, input channel and method, with filter chips and `/` to focus (#38)
- Map: structured vulnerability metadata on every endpoint, plus `domsource`, `domsink` and `taintflow` categories (#36)
- New categories: `waf-facade` — vulnerable pages disguised as WAF-protected (#35), `htmlunsafe` with iframe `srcdoc` sinks, and `navsink` for `javascript:` navigation
- Homebrew tap with prebuilt binaries (#34); VERSION derived from `shard.yml` at compile time (#33)
- Fixes: header-reflection and redirect mazes no longer 500 (#37)

## v0.2.0

- 20 categories to 174 — the bulk of today's catalog. New: jQuery sinks, `codeexec` dynamic code/module execution, `clientstate` web-storage/cookie/history, `apidom` async fetch/XHR, headless PDF/image generator SSRF+XSS, import maps injection, closed Shadow DOM + slot, advanced HTML5 sanitizer bypass, XS-Leaks
- `modern-bypass` levels 9–26
- Dynamic security header overrides via query params
- Kemal route integration spec suite, expanded to dynamic headers, XS-Leaks and advanced bypasses
- A benchmark reporting script for scoring scanners
- Self-registering mazes, `/map` catalog (OpenAPI, sitemap), and per-category exploit guides under `solutions/`
- CI: one unified `ci.yml` with a format check, a modern Crystal matrix and multi-arch docker build validation
- Binds to `127.0.0.1` and runs in production mode by default

## v0.1.0

- First release: 20 maze categories — reflected, DOM, header/path/body injection, JSON, SVG, WebSocket, CSP bypass, template injection, and the shared protections layer
- Docker image
