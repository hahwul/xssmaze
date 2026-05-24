<img src="https://user-images.githubusercontent.com/13212227/228863802-7a020ae4-fe15-48ad-a10a-5e81ac7f9324.png" style="width:200px;">

[![Crystal CI](https://github.com/hahwul/xssmaze/actions/workflows/crystal_build.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal_build.yml)
[![Crystal Lint](https://github.com/hahwul/xssmaze/actions/workflows/crystal_lint.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal_lint.yml)
[![Docker](https://github.com/hahwul/xssmaze/actions/workflows/ghcr.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/ghcr.yml)

XSSMaze is an intentionally vulnerable web application for measuring and improving XSS detection in security testing tools. It covers a wide range of XSS contexts: basic reflection, DOM, header, path, POST, redirect, decode, hidden input, in-JS, in-attribute, in-frame, event handler, CSP bypass, SVG, CSS injection, template injection, WebSocket, JSON, advanced techniques, polyglot, browser-state, opener, storage-event, stream, channel, service-worker, history-state, reparse, and referrer.

![](images/showcase.png)

## Installation

### From Source
```bash
shards install
shards build
./bin/xssmaze
```

### From Docker
```bash
docker pull ghcr.io/hahwul/xssmaze:main
docker run -p 3000:3000 ghcr.io/hahwul/xssmaze:main
```

## Usage
```
./bin/xssmaze

Options:
  -b HOST, --bind HOST             Host to bind (defaults to 127.0.0.1; pass 0.0.0.0 to expose on the network)
  -p PORT, --port PORT             Port to listen for connections (defaults to 3000)
  -s, --ssl                        Enables SSL
  --ssl-key-file FILE              SSL key file
  --ssl-cert-file FILE             SSL certificate file
  -h, --help                       Shows this help
```

## Endpoint Map
```bash
curl http://localhost:3000/map/text         # newline-separated URLs
curl http://localhost:3000/map/json         # full metadata (also: ?type=dom or ?q=csp)
curl http://localhost:3000/map/markdown     # markdown table
curl http://localhost:3000/map/categories   # categories with counts
curl http://localhost:3000/map/openapi      # OpenAPI 3.0 catalog
curl http://localhost:3000/sitemap.xml      # sitemap of all maze paths
curl http://localhost:3000/health           # liveness probe
curl http://localhost:3000/version          # version + counts
curl -L http://localhost:3000/random        # 302 to a random maze
```

The index page (`/`) provides a client-side filter, per-category counts, and links to all of the maps above. Map endpoints serve a payload that is built once at startup, cached, and gzip pre-compressed (`Accept-Encoding: gzip` cuts the index payload by ~85%), so they're safe to poll from tooling.

## XS-Leaks (Cross-Site Leaks)
XS-Leaks are cross-origin side-channels that let an attacker infer state-dependent data without directly reading the response body. XSSMaze includes `xsleak-*` levels that intentionally vary response size, subresource composition, load/error behavior, timing, and redirect chains based on a "secret" state.

The state can be controlled either by:
- `q=admin` (simple stateless demos for scanners), or
- the `xsleak_role=admin` cookie (set via `GET /xsleak/login?as=admin`).

### Levels
- `GET /xsleak/search?q=admin` (`xsleak-level1`): body-size oracle (admin returns more HTML/results)
- `GET /xsleak/frame?q=admin` (`xsleak-level2`): frame-count oracle (admin includes more iframes)
- `GET /xsleak/avatar.gif?q=admin` (`xsleak-level3`): load/error oracle (admin returns an image, guest is 404)
- `GET /xsleak/timing?q=admin` (`xsleak-level4`): timing oracle (guest path sleeps longer)
- `GET /xsleak/redirect?q=admin` (`xsleak-level5`): redirect-chain oracle (admin has more hops)

### Measuring side-channels
To validate dynamically, host an "attacker" page on a different origin and probe the victim endpoints using load/error handlers and timing:

```html
<script>
  // Load/error oracle (200 vs 404)
  const img = new Image();
  img.onload = () => console.log("loaded");
  img.onerror = () => console.log("error");
  img.src = "http://127.0.0.1:3000/xsleak/avatar.gif?q=admin";

  // Timing oracle (measure duration)
  const t0 = performance.now();
  fetch("http://127.0.0.1:3000/xsleak/timing?q=admin", { mode: "no-cors" })
    .finally(() => console.log("ms:", performance.now() - t0));

  // Frame-count oracle (browser-dependent)
  const f = document.createElement("iframe");
  f.src = "http://127.0.0.1:3000/xsleak/frame?q=admin";
  f.onload = () => console.log("subframes:", f.contentWindow.length);
  document.body.appendChild(f);
</script>
```

You can also spot differences via CLI:
```bash
curl -i "http://localhost:3000/xsleak/avatar.gif?q=guest"   # 404
curl -i "http://localhost:3000/xsleak/avatar.gif?q=admin"   # 200 image/gif
curl -s "http://localhost:3000/xsleak/frame?q=guest" | wc -c
curl -s "http://localhost:3000/xsleak/frame?q=admin" | wc -c
curl -sL -o /dev/null -w "%{time_total}\n" "http://localhost:3000/xsleak/timing?q=guest"
curl -sL -o /dev/null -w "%{time_total}\n" "http://localhost:3000/xsleak/timing?q=admin"
```
