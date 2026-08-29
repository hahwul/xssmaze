# Changelog

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
