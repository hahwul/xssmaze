# domsink — solutions

DOM *sinks* the rest of the lab never exercises. The taint always arrives the
same boring way (a `query` parameter read client-side off `location.search`),
so whatever a tool does or does not find here is a statement about the sink,
not the source. All payloads below were verified in Chrome 150.

Note the payload *kind* differs per level: levels 1–2 take HTML, levels 3–5
take raw JavaScript, and levels 6 and 8 take a `javascript:` URL.

### domsink-level1

`/domsink/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `document.implementation.createHTMLDocument()` produces a document
  with no browsing context, so `inert.body.innerHTML = query` loads nothing
  and fires nothing. `document.importNode(inert.body, true)` copies the nodes
  into the live document and appending them activates them. A sink list that
  only knows `innerHTML` sees a write that is genuinely safe at the point it
  happens.

### domsink-level2

`/domsink/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: same inert-document shape as level 1, but with
  `DOMParser.parseFromString` + `document.adoptNode` — the nodes are *moved*
  into the live document rather than copied.

### domsink-level3

`/domsink/level3/?query=alert(1)`

- payload: `alert(1)` (JavaScript, not HTML)
- context: `(0, eval)(query)`. The comma operator detaches `eval` from its
  reference, so this is *indirect* eval and runs in global scope. The call
  shape differs from a plain `eval(x)` that name-based sink lists match on.

### domsink-level4

`/domsink/level4/?query=alert(1)`

- payload: `alert(1)` (JavaScript)
- context: `Reflect.apply(eval, globalThis, [query])` — `eval` is reached
  through the reflection API and never appears in call position.

### domsink-level5

`/domsink/level5/?query=alert(1)`

- payload: `alert(1)` (JavaScript)
- context: `query.split('\n').map(eval)` — `eval` is handed to `.map()` as an
  iteratee, so the tainted value is never syntactically an argument to it.
  Extra `map` arguments (index, array) are ignored because `eval` only reads
  its first parameter. Multiple newline-separated statements each run.

### domsink-level6

`/domsink/level6/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `Object.assign(location, { href: query })`. `Object.assign` invokes
  the `href` setter on `Location`, so the navigation happens exactly as it
  would for `location.href = ...` — but the sink is an `Object.assign` target,
  not an assignment expression.

### domsink-level7

`/domsink/level7/?query=alert(1)`

- payload: `alert(1)` (JavaScript)
- context: `btn.setAttributeNS(null, 'onclick', query)`. The null-namespace
  setter installs an event-handler content attribute exactly like
  `setAttribute` does. The button is clicked programmatically 150 ms after
  load, so no user interaction is required.

### domsink-level8

`/domsink/level8/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `form.action = query` followed by `form.submit()` 150 ms later. A
  `javascript:` action executes on submission — a navigation sink reached
  through the form API rather than through `location`.
