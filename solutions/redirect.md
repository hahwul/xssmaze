# redirect — solutions

Open-redirect endpoints where the `query` param feeds `env.redirect`; XSS via `javascript:` URL when followed in a browser context.

### redirect-level1

`/redirect/level1/?query=javascript:alert(1)`

- payload: `no payload — control`
- context: the value reaches only a `Location:` header on an empty 302 (the value
  to try is `javascript:alert(1)`). Browsers refuse to follow `javascript:` or a
  top-level `data:` from a redirect, so nothing executes (verified: headless
  Chrome navigated the redirect and the beacon stayed silent). The real bug is
  an open redirect, not XSS.

### redirect-level2

`/redirect/level2/?query=javajavascriptscript:alert(1)`

- payload: `no payload — control`
- context: a single non-recursive `javascript` strip that `javajavascriptscript:`
  walks through — the `Location:` header does reassemble to `javascript:alert(1)`
  (verified served), but a redirect sink still cannot execute JS. Open redirect,
  not XSS.

### redirect-level3

`/redirect/level3/?query=javajavascriptscript:alert(1)`

- payload: `no payload — control`
- context: as level2 with the value lowercased first (which closes the mixed-case
  bypass); the nested `javascript` still reassembles in the `Location:` header,
  but a redirect sink executes nothing. Open redirect only.

### redirect-level4

`/redirect/level4/?query=javajavajavascriptscriptscript:alert(1)`

- payload: `no payload — control`
- context: two lowercase-and-strip passes; a triple-nested
  `javajavajavascriptscriptscript:` survives both and reassembles in `Location:`,
  yet the redirect sink still cannot run JS. Open redirect, not XSS.
