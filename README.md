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
  -b HOST, --bind HOST             Host to bind (defaults to 0.0.0.0)
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
