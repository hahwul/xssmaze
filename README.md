<img src="https://user-images.githubusercontent.com/13212227/228863802-7a020ae4-fe15-48ad-a10a-5e81ac7f9324.png" style="width:200px;">

[![Crystal CI](https://github.com/hahwul/xssmaze/actions/workflows/crystal_build.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal_build.yml)
[![Crystal Lint](https://github.com/hahwul/xssmaze/actions/workflows/crystal_lint.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal_lint.yml)
[![Docker](https://github.com/hahwul/xssmaze/actions/workflows/ghcr.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/ghcr.yml)

XSSMaze is an intentionally vulnerable web application for measuring and improving XSS
detection in security testing tools. It serves 1000+ endpoints across 170+ categories —
reflected, DOM, stored, and header/path/body injection, plus filter and WAF bypasses,
CSP gadgets, prototype pollution, template injection, and modern DOM sink/source shapes
that defeat naive taint analysis.

Every endpoint ships structured metadata, so a benchmark can score per vulnerability
class instead of regex-guessing at the served HTML.

![](images/showcase.png)

> [!WARNING]
> This app is deliberately vulnerable. It binds to `127.0.0.1` by default — only pass
> `-b 0.0.0.0` on a network you trust.

## Install

```bash
docker run -p 3000:3000 ghcr.io/hahwul/xssmaze:main
```

Or from source:

```bash
shards install && shards build
./bin/xssmaze
```

## Usage

```
./bin/xssmaze [options]

  -b HOST, --bind HOST     Host to bind (default 127.0.0.1)
  -p PORT, --port PORT     Port to listen on (default 3000)
  -s, --ssl                Enable SSL
  --ssl-key-file FILE      SSL key file
  --ssl-cert-file FILE     SSL certificate file
  -h, --help               Show help
```

## Endpoint map

| Endpoint | Returns |
|----------|---------|
| `/map/text` | newline-separated URLs |
| `/map/json` | full metadata; filter with `?type=`, `?q=`, `?vuln=`, `?reach=`, `?exploitable=` |
| `/map/markdown` | markdown table |
| `/map/categories` | categories with counts + class/reach rollups |
| `/map/openapi` | OpenAPI 3.0 catalog |
| `/sitemap.xml` | sitemap of all maze paths |
| `/stats` | aggregate counts by class, reach, source, and sink |
| `/health` | liveness probe (`/healthz` alias) |
| `/version` | version + counts |
| `/random` | 302 to a random maze |

```bash
curl "http://localhost:3000/map/json?vuln=dom"           # only DOM flows
curl "http://localhost:3000/map/json?reach=server"       # payload fits in an HTTP request
curl "http://localhost:3000/map/json?exploitable=false"  # deliberate true negatives
```

The index page (`/`) has a client-side filter and links to every map above. Map responses
are built once at startup, cached, and gzip pre-compressed (`Accept-Encoding: gzip` cuts
the index by ~85%), so they are safe to poll from tooling.

## Vulnerability metadata

Every endpoint in `/map/json` carries a `vuln` object:

```json
{
  "name": "dom-level7",
  "url": "/dom/level7/",
  "params": ["#hash"],
  "vuln": {
    "class": "dom",
    "reach": "client",
    "delivery": ["fragment"],
    "sources": ["location.hash"],
    "sinks": ["innerHTML"],
    "exploitable": true,
    "note": null
  }
}
```

| Field | Meaning |
|-------|---------|
| `class` | `reflected-html`, `reflected-attr`, `reflected-js`, `dom`, `stored`, `prototype-pollution`, `csti`, `non-xss-control`, or `unclassified` |
| `sources` / `sinks` | DOM taint endpoints, e.g. `location.hash` → `innerHTML` |
| `delivery` | where the payload enters: `query`, `path`, `body`, `header`, `cookie`, `referer`, `fragment`, `postmessage`, `window-name`, … |
| `reach` | derived — `server` if any delivery channel fits an HTTP request, `client` if the payload only exists browser-side, `unknown` if untriaged |
| `exploitable` | `false` marks a deliberate control / true negative |
| `note` | caveats: required interaction, why it is a control, non-obvious parameter names |

Classification follows the **injection context** — where the bytes land — not what the
receiving API does with a well-formed argument. A value reflected raw into a JS string
literal is `reflected-js` however inert the function it is passed to.

Two things this exists to stop a benchmark getting wrong:

- **`reach: "client"`** endpoints (fragment, postMessage, window.name, clipboard,
  drag-and-drop) cannot be reached by a request-only scanner at all. Counting them as
  misses measures the wrong thing.
- **`exploitable: false`** endpoints are not bugs. The whole `xsleak` category is
  cross-site *leaks*, not XSS — a scanner that reports nothing there is correct.

Untriaged endpoints are `"unclassified"` with `reach: "unknown"`, deliberately distinct
from "reviewed and found safe".

## Security header overrides

To calibrate scanners against different defensive configurations, any endpoint accepts
per-request header overrides via query params:

| Param | Sets |
|-------|------|
| `set_csp` | `Content-Security-Policy` (URL-encode spaces/quotes) |
| `set_xcto` | `X-Content-Type-Options` (e.g. `nosniff`) |
| `set_xfo` | `X-Frame-Options` (e.g. `DENY`) |

```bash
curl -i "http://localhost:3000/basic/level1/?query=a&set_csp=default-src%20%27self%27"
```

## XS-Leaks

`xsleak-*` levels are cross-origin side-channels that vary response size, subresource
count, load/error behavior, timing, and redirect depth by a "secret" state. State comes
from either `q=admin` or the `xsleak_role=admin` cookie (set via `GET /xsleak/login?as=admin`).

| Level | Endpoint | Oracle |
|-------|----------|--------|
| 1 | `/xsleak/search?q=admin` | body size (admin returns more results) |
| 2 | `/xsleak/frame?q=admin` | frame count |
| 3 | `/xsleak/avatar.gif?q=admin` | load/error (admin 200, guest 404) |
| 4 | `/xsleak/timing?q=admin` | timing (guest path sleeps longer) |
| 5 | `/xsleak/redirect?q=admin` | redirect-chain depth |

These are *leaks*, not XSS — they are marked `exploitable: false` and a scanner reporting
nothing here is behaving correctly. Spot the difference from the CLI:

```bash
curl -s "http://localhost:3000/xsleak/frame?q=guest" | wc -c
curl -s "http://localhost:3000/xsleak/frame?q=admin" | wc -c
curl -sL -o /dev/null -w "%{time_total}\n" "http://localhost:3000/xsleak/timing?q=admin"
```

To measure them properly, host a page on a different origin and probe with load/error
handlers, timing, and `iframe.contentWindow.length`.

## Benchmarking scanners

`scripts/benchmark.py` pulls every endpoint from `/map/json`, runs a scanner against
them, and prints a detection scorecard.

```bash
./bin/xssmaze -b 0.0.0.0          # terminal 1
cd scripts && ./benchmark.sh http://localhost:3000   # terminal 2
```

Nuclei is supported out of the box; any other tool can be wired in with
`--custom-scanner "mytool {URL}"`. See [scripts/README.md](scripts/README.md) for
options, report formats, and how to add a scanner permanently.

## License

MIT
