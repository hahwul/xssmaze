# Changelog

## v0.4.0

- Fixed `modern-bypass-level19`: an escaping typo made its inline `<script>` a SyntaxError, so the postMessage → `eval` flow never registered. It is a real DOM flow again, verified in headless Chrome via `/beacon` (#58)
- The lab no longer 500s on bare requests: missing params raised `KeyError`, 500ing 768 of 1031 GET mazes. All non-optional reads now default; smoke spec covers bare paths and lone params (#53, #54, #55, #56)
- Every endpoint is classified: `unclassified` 838 → 0, so `/map/json?reach=server` now returns 1040 reachable endpoints instead of 206. 28 marked `exploitable: false` after headless-Chrome review (#47, #48, #49, #50)
- Answer key served: `solutions/` is embedded at compile time and served as `/solutions.json`, `/solutions/<category>` and `/map/json?with=solutions`, with a parity spec (#46)
- Execution oracle: `/beacon/<token>` records that a payload *ran* and `/beacon/log` reports it with the firing `Referer`, so benchmarks can score DOM flows the response never reflects (#44)
- Scorecard fixed: `scripts/benchmark.py` now reports TP/FN/FP with precision/recall/F1, excludes `exploitable: false`, picks its population with `--reach`, and requires an explicit `--detect-regex`/`--detect-json` contract (#45)
- Cookie reflections no longer 500: `HTTP::Cookie` rejected the bytes these levels exist to reflect. New `Xssmaze.cookie_value` keeps the reflection; a smoke spec walks the whole catalog (#43)
- Stored mazes are bounded and resettable: collections keep only recent entries and `/reset` clears them between runs, so one scanner run no longer reads back another's payloads (#42)
- Fixed `params:` lists that named a parameter the handler never reads, which told scanners to fuzz the wrong field; the 26 contradicting endpoints are now 0
- Kemal 1.13.0, Crystal floor `>= 1.12.0`. Kemal now rejects a WebSocket without an `Origin`, so `/domsource/level7/echo` 403'd wscat, fuzzers and raw curl upgrades — `Server.start!` opts back into allow-all, pinned by a spec (#41)
- Two more Kemal 1.13 behaviour changes reach the lab, both improvements: a malformed JSON body now answers 400 instead of 500, and a file upload's temp file is cleaned up however the request ends (#41)
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
