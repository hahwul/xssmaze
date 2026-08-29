# xsleak — solutions

Cross-site-leak (XS-Leaks) oracles, **not** XSS. Each level exposes a
guest-vs-admin state difference an attacker could probe cross-origin (response
size, frame count, image load/error, timing, redirect-chain length). They carry
`vuln.class = "non-xss-control"` / `vuln.exploitable = false` in `/map/json`:
there is no injection sink, so a scanner reporting **no XSS** here is correct.
Sign in first via `/xsleak/login?as=admin` to observe the admin branch.

### xsleak-level1

`/xsleak/search?q=admin`

- payload: `no payload — control`
- context: body-size oracle (probe with `q=admin`); admin returns ~60 results plus hidden filler, guest ~6 — the response length leaks the role. No sink to inject. XS-Leak, not XSS.

### xsleak-level2

`/xsleak/frame?q=admin`

- payload: `no payload — control`
- context: frame-count oracle (probe with `q=admin`); admin embeds 12 subframes, guest 1 — `window.frames.length` leaks the role cross-origin. No sink to inject. XS-Leak, not XSS.

### xsleak-level3

`/xsleak/avatar.gif?q=admin`

- payload: `no payload — control`
- context: image load/error oracle (probe with `q=admin`); admin gets a valid GIF (onload), guest a 404 (onerror). No sink to inject. XS-Leak, not XSS.

### xsleak-level4

`/xsleak/timing?q=admin`

- payload: `no payload — control`
- context: response-timing oracle (probe with `q=admin`); the guest branch sleeps ~250ms, admin ~10ms — measurable cross-origin. No sink to inject. XS-Leak, not XSS.

### xsleak-level5

`/xsleak/redirect?q=admin`

- payload: `no payload — control`
- context: redirect-chain-length oracle (probe with `q=admin`); admin follows 5 hops, guest 1 — observable via fetch/redirect counting. No sink to inject. XS-Leak, not XSS.
