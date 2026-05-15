# XSSMaze — solution guides

Per-category exploit notes for every endpoint in the lab. The lab itself runs
`./bin/xssmaze` (default `http://127.0.0.1:3000`); each entry below shows a
working payload for one or more maze levels.

**Total**: 162 categories · 942 levels.

## How to read an entry

```
### <maze-name>

`<full URL with payload, URL-encoded where the URL would otherwise be invalid>`

- payload: `<raw decoded payload>`
- context: <one-line note about where the input lands and any non-trivial filter>
```

- The URL line is paste-able into a browser address bar. Special chars are
  URL-encoded so the URL parses; the `payload:` line keeps the decoded form
  for readability.
- POST endpoints use `[POST] /path/` + a `body: field=<payload>` line.
- Header-driven endpoints use `[Header] /path/` + a `header: <Name>: <value>` line.
- DOM sinks driven by `location.hash` / `window.name` / postMessage carry the
  payload in the URL fragment and note the trigger in `context:`.

## Caveats

- Four categories cover two URL paths each because their solutions share
  filter logic. See [Merged categories](#merged-categories) below.
- A handful of levels are intentionally hardened (e.g. `sanitizer-level5`,
  `shadow-dom-level5`, `slot-level4`, `stored-level2`, `waf-bypass-level5`,
  `mutfilter-level1`). Those entries document the constraint instead of a
  fabricated payload.

## Merged categories

| File | Covers URL paths |
|------|------------------|
| [hidden](hidden.md) | `/hidden/`, `/hidden-reflection/` |
| [prototype](prototype.md) | `/prototype-pattern/`, `/prototype-pollution/` |
| [realworld](realworld.md) | `/realworld/`, `/realworld-encoding/` |
| [sanitizer](sanitizer.md) | `/sanitizer/`, `/sanitizer-edge/` |

## Categories

| Category | Description |
|----------|-------------|
| [advanced](advanced.md) | Advanced XSS sinks: WAF keyword strip, MutationObserver, Service Worker message, Web Components, Trusted Types stub, and Proxy innerHTML. |
| [api-response](api-response.md) | Non-HTML response shapes (JSON/XML/CSV/JSONP) served with text/html so the body is parsed as HTML. |
| [ariaattr](ariaattr.md) | Reflection inside double-quoted ARIA attributes; break out of the attribute then add an event handler. |
| [attr-event](attr-event.md) | Reflections inside single-quoted JS strings within inline event handlers; close the string and inject JS. |
| [attrctx](attrctx.md) | Reflections inside HTML attribute values across input/href/src/style/iframe contexts. |
| [attrname](attrname.md) | User controls a raw attribute name on an existing tag; supply an event handler or break out via the surrounding quote. |
| [basic](basic.md) | Raw body reflection with progressive filters on quotes, parens, and backticks. |
| [booleanattr](booleanattr.md) | Reflection inside double-quoted boolean attribute values; break out and inject a tag. |
| [browser-state](browser-state.md) | DOM-only sinks where the seed is relayed through browser state (window.name, localStorage, sessionStorage, postMessage, document.referrer) and then written via innerHTML / insertAdjacentHTML / createContextualFragment / srcdoc / document.write. |
| [bugbounty](bugbounty.md) | Patterns from real bug-bounty reports / CVEs: OAuth flows, JWT/reset tokens, upload previews, third-party widgets, cache poisoning. |
| [callback](callback.md) | JSONP-style and callback-name injection sinks. |
| [casemanip](casemanip.md) | Case-manipulation transforms (lowercase tags, ROT13, title-case, strip uppercase) — HTML is case-insensitive so most payloads survive. |
| [chain](chain.md) | Chained / partial keyword filters — pick payloads that survive the substitution. |
| [channel](channel.md) | Seed parameter relayed through web channels (BroadcastChannel, MessageChannel, Worker) into innerHTML / insertAdjacentHTML / createContextualFragment / srcdoc. |
| [charlimit](charlimit.md) | Single-character stripping filters; choose a payload that doesn't need the stripped char. |
| [clipboard](clipboard.md) | Clipboard-mediated sinks: the seed is JSON-escaped into a JS prefix string, then concatenated with clipboard content and written via innerHTML. Triggering requires the user paste/copy interaction described per level. |
| [cmspattern](cmspattern.md) | Raw reflections mimicking CMS templates (WordPress / Drupal / Joomla / Ghost / Medium). |
| [commentinj](commentinj.md) | Reflections inside HTML / JS comments — close the comment then inject. |
| [complexpage](complexpage.md) | Full-page templates with reflection nested in body / sidebar / titles / styled paragraphs / tables. |
| [condreflect](condreflect.md) | Conditional reflection — payload must satisfy the gate (length, contains digit, doesn't start with <, etc.). |
| [csp](csp.md) | CSP-protected reflections with various policy weaknesses (unsafe-inline, nonce reuse, unsafe-eval, data: child, meta-tag). |
| [cspbypass](cspbypass.md) | Reflections under various CSP configurations that fail to actually prevent execution. |
| [css](css.md) | CSS sinks that can pivot to script execution (legacy expression(), @import, url(), content, attr). |
| [csti](csti.md) | Client-side template injection via AngularJS / Vue / jQuery sinks. |
| [ctxescape](ctxescape.md) | Mixed JS / CSS / HTML-comment / unquoted-attr contexts — escape the surrounding context first. |
| [ctxv2](ctxv2.md) | Reflection inside raw-text HTML elements (comment / textarea / title / style / noscript) and inside iframe srcdoc. |
| [ctype](ctype.md) | Reflections under unusual Content-Type values (XML/XHTML/CDATA/JSONP/SVG/nosniff). |
| [customtag](customtag.md) | Reflections inside custom elements, is= built-ins, slots, templates, output. |
| [dashboard](dashboard.md) | Raw reflections in typical admin/dashboard widgets (cards, alerts, tables, modals, badges). |
| [data-attribute](data-attribute.md) | Reflections inside HTML data-* attributes with single/double-quote contexts. |
| [dataurl](dataurl.md) | Reflections into data:text/html sinks via href / src / data attributes. |
| [dblenc](dblenc.md) | Server decodes (URL twice / HTML entities / base64 / URL once) before reflection. |
| [decode](decode.md) | Server decodes the query (base64 / URL / double) before reflection. |
| [dialog](dialog.md) | Reflections inside `<dialog>` element bodies, attributes, and JS sinks. |
| [dom](dom.md) | Client-side DOM sinks driven by URL, hash, query, name, referrer, postMessage. |
| [domctx](domctx.md) | Server reflections that land in JS strings, JSON, eval, or div bodies (DOM contexts). |
| [doublereflect](doublereflect.md) | Same input reflected in multiple places — exploit the weaker sink. |
| [dragdrop](dragdrop.md) | Reflections passed through to_json into JS, used in drag-and-drop sinks. |
| [ecommerce](ecommerce.md) | Raw reflections in storefront widgets (titles, prices, filters, cart, reviews, breadcrumbs). |
| [edge](edge.md) | Edge cases: null-byte tricks, path segment, JSON island, SVG attr, split params, textarea. |
| [edgefilter](edgefilter.md) | Quirky filter implementations: keyword strip, single-pass tag regex, partial encoding. |
| [email-template](email-template.md) | Raw reflections inside HTML email templates (welcome, reset link, order, newsletter, alert, invoice). |
| [embedctx](embedctx.md) | Reflections inside object/embed/param/applet attributes — break attribute or use data:text/html. |
| [encmix](encmix.md) | Charset and encoding tricks (UTF-7, partial entity encode, JS string escape, JSON-as-HTML, ISO-8859-1). |
| [encoding-bypass](encoding-bypass.md) | Server filter strategies bypassable via case mix, double-encoding, alternative tags, etc. |
| [encodingedge](encodingedge.md) | Partial / case-sensitive / positional encoding filters with bypass paths. |
| [errhandling](errhandling.md) | Raw reflections in error/exception/validation/rate-limit views. |
| [errpage](errpage.md) | Raw reflection of the query parameter into HTML error/debug pages across different host elements. |
| [eventhandler](eventhandler.md) | Reflection injected directly into a `<div>` tag's attribute area (`<div QUERY>`), with `<` and `>` stripped and progressively stronger event-handler denylists. |
| [filterchain](filterchain.md) | Multiple stacked filters (tag blacklist, event-handler regex, protocol strip, lowercase, quote strip, etc.) — each level needs a payload that bypasses the actual combined filter. |
| [formaction](formaction.md) | Reflection in `formaction` / `action` URL attributes — `javascript:` URI works in form submission context. |
| [formelement](formelement.md) | Reflection inside various form-element attributes (`placeholder`, `title`, `name`, `value`, `for`) — break out of the double-quoted attribute and inject. |
| [fragment](fragment.md) | Reflection inside various host tags (`option`, `pre`, `svg`, `math`, `details`, `marquee`) — close the host and inject. |
| [fwoutput](fwoutput.md) | Framework-style templates (Django/Rails/Express/Spring/Laravel/.NET) all reflect the query raw into HTML; no real filter. |
| [globalattr](globalattr.md) | Reflection in various global HTML attributes (`id`, `class`, `accesskey`, `spellcheck`, `draggable`, `lang`) — all double-quoted, break out and inject. |
| [header](header.md) | Raw header values reflected as the entire response body — set the header to a script payload. |
| [headerinj](headerinj.md) | Various request headers (Referer, User-Agent, X-Forwarded-For, Cookie, Accept-Language, X-Debug) reflected into HTML body/attributes/comments. |
| [hidden](hidden.md) | Reflection in hidden / non-visible sinks: `<input type=hidden>`, meta refresh, data attributes, JSON/CSS/noscript blocks. |
| [history-state](history-state.md) | DOM sinks where `?seed` is stored via `history.replaceState` and then read back into `innerHTML` / `srcdoc`. |
| [hpp](hpp.md) | HTTP parameter pollution: duplicate names, array suffixes, and dot-notation reflections. |
| [import-map](import-map.md) | Reflection into `<script type="importmap">` JSON or dynamic `import()` specifier. A user-controlled module URL can return JS that the browser executes. |
| [inattr](inattr.md) | Reflection inside a `<div class>` attribute under various quoting and filter combinations. |
| [inframe](inframe.md) | Reflection into `<iframe src='...'>` with progressively stronger filters on quotes / `javascript:` / `alert`. |
| [injs](injs.md) | Reflection inside a `<script>` block — JS variable, string, or comment context. |
| [inlinestyle](inlinestyle.md) | Reflection inside an inline `style="..."` attribute — break out of the double-quoted attribute and add an event handler. |
| [inputtransform](inputtransform.md) | Reflection after a server-side transform (prefix, tag wrap, split, reverse, lowercase). Pick a payload that survives. |
| [jf](jf.md) | Reflection inside `<script>` with all `[a-zA-Z]` stripped — must construct an exploit using only digits and symbols. |
| [jsctx](jsctx.md) | Reflection inside `<script>` blocks across various JS contexts (string, object key, array, function arg, regex, comment). |
| [jsescape](jsescape.md) | JS string contexts where the matching quote/backslash is escaped but `</script>` is never blocked — close the script tag. |
| [json](json.md) | JSON-context reflections: JSONP callbacks, embedded JSON in script blocks, and DOM sinks. |
| [jsonctx](jsonctx.md) | JSON-shaped responses that are still treated as HTML (text/html content-type) or are embedded inside `<script>` blocks. |
| [latereflect](latereflect.md) | Reflections placed deep on the page after large padding blocks; payload itself is unfiltered. |
| [linkcontext](linkcontext.md) | Reflections inside link-style URL/href attributes; many allow `javascript:` directly. |
| [listiteration](listiteration.md) | Input split on a delimiter and each chunk rendered into HTML — inject in a single chunk. |
| [manifest](manifest.md) | Page fetches its own manifest.json and innerHTMLs a field; client-side sink. |
| [markdown](markdown.md) | Markdown renderer bugs: missing scheme checks, raw HTML pass-through, unescaped attribute fields. |
| [mathml](mathml.md) | MathML parser quirks that allow HTML execution inside math contexts. |
| [mediacontext](mediacontext.md) | Reflections inside media element src/alt attributes — break out of attribute. |
| [metarefresh](metarefresh.md) | `<meta http-equiv=refresh>` URL injection; data: URI bypasses are the typical sink. |
| [microdata](microdata.md) | Reflections inside microdata/RDFa attributes — break out of double-quoted attribute. |
| [misc-context](misc-context.md) | Reflections inside lesser-used HTML element attributes (progress/meter/time/data/cite/q). |
| [mixed-method](mixed-method.md) | Endpoints with varied HTTP methods and parameter names; reflections are mostly raw. |
| [mobserver](mobserver.md) | MutationObserver re-applies content into unsafe sinks; DOM-based. |
| [modern](modern.md) | Modern framework / SaaS XSS shapes: dangerouslySetInnerHTML, markdown, hydration mismatch, etc. |
| [multicontext](multicontext.md) | Same input lands in multiple contexts; at least one is exploitable. |
| [multiline](multiline.md) | Reflections in contexts where newlines or block-element nesting matter. |
| [multiparam](multiparam.md) | Multiple parameters; requires correct param combination to reach the reflection. |
| [multipart](multipart.md) | POST body, raw JSON body, and header-based reflections. |
| [multipleoutput](multipleoutput.md) | Multiple reflection points; some encoded, at least one raw — pick the raw sink. |
| [multireflect](multireflect.md) | One parameter reflected into multiple contexts on a single page. |
| [multivector](multivector.md) | Multiple sinks/forms/inputs on a single page; identify the reflection point. |
| [mutfilter](mutfilter.md) | Reflections with mutation/regex filters that can be bypassed. |
| [mxss](mxss.md) | Mutation XSS via innerHTML round-trip / DOMParser / template / namespace switching. |
| [nestedctx](nestedctx.md) | Reflections inside nested HTML/JS/CSS contexts; break out of the inner context. |
| [nestedfilter](nestedfilter.md) | Layered/sequential filters where one filter's output enables a bypass that survives the next. |
| [nonce](nonce.md) | CSP nonce-based protections bypassed via injection inside trusted contexts. |
| [noscript](noscript.md) | Reflections inside <noscript> elements and related mutation/breakout tricks. |
| [numericcontext](numericcontext.md) | Reflections in numeric-only positions (JS numbers, CSS/HTML numeric attributes). |
| [obfuscation](obfuscation.md) | Server-side case/space/char-stripping that fails against case-insensitive HTML or alt syntax. |
| [opener](opener.md) | window.opener-based bootstrap where the first request seeds data read by the popup. |
| [partial-encode](partial-encode.md) | Incomplete HTML encoding (one char, first-only, wrong chars) leaving exploitable contexts. |
| [path](path.md) | URL path-segment reflections; some strip encoded slash/space sequences. |
| [pathxss](pathxss.md) | Page-template reflections (paragraph, breadcrumb, title, canonical href, dual sinks). |
| [payloadfilt](payloadfilt.md) | Coarse keyword/regex/length blacklists bypassed via context or syntax. |
| [pdiff](pdiff.md) | Parser differential contexts: noscript, foster parenting, MathML, xmp, srcdoc. |
| [polyctx](polyctx.md) | Multiple reflection contexts on one page; any single context suffices. |
| [polyglot](polyglot.md) | Single-context polyglot challenges (HTML comment, meta refresh URL, multi-decode). |
| [popover](popover.md) | HTML popover API sinks (innerHTML/showPopover/attribute breakouts). |
| [post](post.md) | Basic POST body reflection (form + JSON). |
| [postmethod](postmethod.md) | POST method reflection variants (form, JSON, value attr, script string). |
| [prototype](prototype.md) | JS prototype-pollution gadgets and CMS/framework-style raw reflections. |
| [racecon](racecon.md) | Reflections in special-tag contents (style, textarea, svg text, title). |
| [realworld-input](realworld-input.md) | Real-world input vectors: headers, JSON/multipart bodies, redirect sinks, cookies, paths, JSONP. |
| [realworld](realworld.md) | Real-world reflection patterns: double sinks, debug flags, truncation, headers, encoding chains. |
| [recfilt](recfilt.md) | Non-recursive (single-pass) filters that can be bypassed by nested duplication or alternative sinks. |
| [redirect](redirect.md) | Open-redirect endpoints where the `query` param feeds `env.redirect`; XSS via `javascript:` URL when followed in a browser context. |
| [redirectxss](redirectxss.md) | Reflections into URL-valued attributes (href, meta refresh, form action, object data, JS window.location). |
| [referrer](referrer.md) | DOM XSS via `document.referrer`: the seed value is parsed from the referrer URL and fed to a fragment/template sink. Trigger by navigating from a URL containing `seed=<payload>`. |
| [regexbypass](regexbypass.md) | Real-world WAF / regex bypass shapes: missing `/i`, slash separator, entity decode-after-filter, single-pass nesting, encode-decode mismatch, blacklist gaps. |
| [regexfilt](regexfilt.md) | Regex-based filters that miss alternative tags, attribute styles, or scheme variations. |
| [reparse](reparse.md) | DOM sinks that take a query param, repeatedly reparse it through URLSearchParams / nested wrappers, then dump into innerHTML or iframe srcdoc. |
| [replacementfilter](replacementfilter.md) | String-replacement filters that miss case variants, nested duplication, or substring patterns. |
| [respheader](respheader.md) | Various response-header configurations that do not actually block reflected XSS in the body. |
| [rsplit](rsplit.md) | Reflections that land in both headers/cookies and body; body injection works directly. |
| [rwpattern](rwpattern.md) | Real-world page templates (search, profile, 404, comments, admin, API docs). |
| [sanitizer](sanitizer.md) | Hand-rolled sanitizers that pass the most-obvious payload but break on context or attribute edge cases. Covers `sanitizer-...` and `sanitizer-edge-...`. |
| [scanbounty](scanbounty.md) | Real-world bug-bounty reflection shapes a stock scanner can catch. |
| [scriptgadget](scriptgadget.md) | Reflections inside `<script>` JS literals or event-handler attrs; closing the script tag (or breaking the JS string) yields XSS. |
| [semantictag](semantictag.md) | Plain HTML-body reflections inside semantic block elements (article, section, aside, nav, footer, main/blockquote). No filtering. |
| [seoctx](seoctx.md) | Reflections inside SEO/meta `content=` / `href=` attributes; break attribute and inject new tag. |
| [service-worker](service-worker.md) | Synthetic ServiceWorker `message` event dispatched with the seed value as `event.data`; sinks innerHTML or iframe srcdoc. |
| [shadow-dom](shadow-dom.md) | Open/closed shadow root sinks. Scripts inside shadow innerHTML do not execute, but `<img onerror>` / `<svg onload>` do. |
| [sink](sink.md) | Reflections into a variety of URL-like or DOM sinks (href, location, action, embed/object, data-attr to innerHTML). |
| [slot](slot.md) | Web-component `<slot>` reflections — light DOM text/attribute interpolation that ends up rendered inside the shadow root. |
| [social-media](social-media.md) | Social-feed style reflections (tweet text, mention, hashtag href, bio, comment, share link). Mostly raw HTML body or attribute injections. |
| [specialchar](specialchar.md) | Filters that strip a single special character (backslash, semicolon, colon, null) or perform URL-decoding before reflecting. |
| [specialtag](specialtag.md) | Reflections inside attributes of less-common tags (option, meta, button, base, img alt, iframe srcdoc, object, unquoted img src). |
| [srcdoc](srcdoc.md) | Reflection into `<iframe srcdoc="...">` — scripts inside srcdoc execute in iframe context. |
| [srcset](srcset.md) | Single-quote attribute injection in srcset / imagesrcset of img / source / link tags. |
| [storage-event](storage-event.md) | Listener iframe registers a `storage` event handler; the parent localStorage.setItem triggers the listener which sinks `newValue` / `oldValue` into innerHTML or iframe srcdoc. |
| [stored](stored.md) | Classic stored XSS endpoints: input persisted server-side, then reflected on subsequent renders. |
| [storedpat](storedpat.md) | Realistic stored XSS shapes (comments, bios, reviews, chat, tickets, admin notes) reflected via POST then GET. |
| [stream](stream.md) | Streaming sinks (EventSource / WebSocket / SharedWorker) where seed is dispatched to a message handler that hits innerHTML, srcdoc, or createContextualFragment. |
| [svg](svg.md) | Reflection inside SVG event handlers, animate values, foreignObject scripts, use href, data: URIs. |
| [svgctx](svgctx.md) | Reflection inside SVG sub-elements (text/desc/title/xlink:href/foreignObject/animate). |
| [tablecontext](tablecontext.md) | Plain reflections inside table-related and list-related text elements; no filtering. |
| [tagattrmix](tagattrmix.md) | Mixed reflection in tag content and various attributes; pick the simplest breakout. |
| [template](template.md) | Server-side and client-side template-style substitution sinks under `/template/`. |
| [timing](timing.md) | Reflection in various JS literal contexts (string, object key, comment, regex, template). |
| [tplel](tplel.md) | HTML `<template>` element reflections: inert content reactivated via innerHTML/appendChild. |
| [tplinject](tplinject.md) | Template-injection-style XSS through JS template literals, `<template>` cloning, `script type=text/template`, double-render, and data-attribute → innerHTML pipes. |
| [truncation](truncation.md) | Length-truncated reflections; pick short payloads that fit the cap. |
| [trustedtypes](trustedtypes.md) | Trusted Types misconfigurations (report-only, permissive default policy, partial sanitization). |
| [unicode](unicode.md) | Unicode normalization / charset / null-byte / backslash quirks in filters. |
| [url-param-ctx](url-param-ctx.md) | Reflection inside URL query parameter values placed in href/src/action attributes; break out of the attribute. |
| [waf-bypass](waf-bypass.md) | Classic WAF bypass filters: keyword strip, event strip, quote escape, single-side angle strip, lowercase, equals strip. |
| [wafv2](wafv2.md) | Round-2 WAF-style filter bypasses (keyword strip, event-handler strip, function name strip, length cap, partial tag strip, mixed filters). |
| [websocket](websocket.md) | WebSocket-style message handlers that consume user input into innerHTML, JSON parse, eval, attribute setters, or stream-message bootstraps. |
| [whitespace](whitespace.md) | Whitespace-normalizing filters; pick delimiters that survive. |
| [worker](worker.md) | Web Worker relays: payload travels through the worker boundary and the page innerHTMLs the worker's response. |
| [wrappercontext](wrappercontext.md) | Plain reflections wrapped in inline formatting tags; no filtering. |
| [xmlctx](xmlctx.md) | XML/XHTML-shaped pages served as text/html; deprecated container elements and PI. |
