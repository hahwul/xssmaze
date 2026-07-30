# domsource — solutions

DOM taint *sources* the rest of the lab never exercises. Every level ends in a
boring sink (`innerHTML` / `insertAdjacentHTML` / `document.write`) on purpose,
so whatever a tool does or does not find here is a statement about the source,
not the sink. All payloads below were verified in Chrome 150.

Standard payload unless noted: `<img src=x onerror=alert(1)>`.

### domsource-level1

`/domsource/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the value is written to an IndexedDB object store, then read back
  out through `transaction().objectStore().get()` — two async callbacks away
  from the write — and rendered with `innerHTML`. Because it is persisted, the
  level keeps firing on later visits to `/domsource/level1/` with no parameter
  at all.

### domsource-level2

`/domsource/level2/#msg=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment, under the
  `msg` key)
- context: `new URLSearchParams(location.hash.slice(1)).get('msg')` — SPA hash
  routing where the fragment is itself a querystring. Tools that treat
  `location.hash` as one opaque string miss the named key inside it.

### domsource-level3

`/domsource/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the value is stashed on the current history entry with
  `replaceState`, a throwaway entry is pushed on top, and `history.back()`
  fires `popstate` with the seeded state — which the handler feeds to
  `insertAdjacentHTML`. The sink is unreachable without the back navigation.

### domsource-level4

`/domsource/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the server only reflects into a `<script src>` URL. The external
  script `/domsource/level4/boot.js` reads its *own* URL back out of
  `document.currentScript.src`, pulls the `msg` parameter off it, and
  `document.write`s it — the embeddable-widget configuration pattern.

### domsource-level5

`/domsource/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the `innerHTML` assignment lives inside
  `navigator.permissions.query({name:'notifications'}).then(...)`. No
  synchronous path through the page reaches the sink.

### domsource-level6

`/domsource/level6/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: the fragment is stored on a CSS custom property with
  `style.setProperty('--maze-label', ...)`, read back through
  `getComputedStyle().getPropertyValue()`, and handed to
  `insertAdjacentHTML` — the taint round-trips through the CSSOM.
- caveat: the value must stay a valid CSS declaration value. Avoid quotes,
  `;`, `!` and unbalanced brackets; `<img src=x onerror=alert(1)>` is fine
  because its parentheses are balanced and it has no quotes.

### domsource-level7

`/domsource/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: a *real* same-origin WebSocket. The page connects to
  `/domsource/level7/echo`, sends the query parameter, and `innerHTML`s the
  frame the server echoes back. Unlike the older `websocket-xss` / `stream`
  levels — which call `onmessage` by hand with a synthetic `MessageEvent` —
  the taint here genuinely crosses a network boundary.
