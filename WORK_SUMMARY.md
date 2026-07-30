# Work summary — DOM metadata & coverage

Branch: `hahwul/dom-metadata-and-coverage`. Four commits, nothing pushed.

| | before | after |
|---|---|---|
| endpoints | 1036 | 1059 |
| categories (`/version`) | 171 | 174 |
| endpoints with vuln metadata | 0 | 221 |
| endpoints marked as controls | 0 | 6 |

Verification: `shards build`, `crystal spec` (110 examples, 0 failures),
`crystal tool format`, `ameba` (195 files, 0 failures), and a boot of
`KEMAL_ENV=production ./bin/xssmaze -p 3100` with `/map/json`,
`/map/categories`, `/map/openapi`, `/stats`, `/version`, `/health` all parsing
as JSON.

Exploitability claims were checked empirically, not asserted: every new level
and every disputed existing one was loaded in headless Chrome 150 over the
DevTools Protocol, with `Page.javascriptDialogOpening` as the oracle.

---

## Weakness 1 — machine-readable vulnerability metadata

### Schema

Every endpoint in `/map/json` now carries a `vuln` object:

```json
{
  "name": "dom-level7",
  "url": "/dom/level7/",
  "type": "dom",
  "desc": "innerHTML (location.hash)",
  "method": "GET",
  "params": ["#hash"],
  "vuln": {
    "class": "dom",
    "reach": "client",
    "delivery": ["fragment"],
    "sources": ["location.hash"],
    "sinks": ["innerHTML"],
    "exploitable": true,
    "note": null
  }
}
```

| Field | Type | Meaning |
|-------|------|---------|
| `class` | closed enum | `unclassified`, `reflected-html`, `reflected-attr`, `reflected-js`, `dom`, `stored`, `prototype-pollution`, `csti`, `non-xss-control` |
| `sources` | `string[]` | DOM taint origins — `location.hash`, `location.search`, `document.referrer`, `postMessage`, `localStorage`, `indexedDB`, `dataTransfer`, `clipboardData`, `dataset`, `fetch-response`, `websocket-message`, `currentScript.src`, `css-custom-property`, `popstate`, `server-reflected`, … |
| `sinks` | `string[]` | DOM taint sinks — `innerHTML`, `document.write`, `eval`, `Function`, `srcdoc`, `location-nav`, `script.src`, `importNode`, `adoptNode`, `indirect-eval`, `form-submit`, `jquery.html`, … |
| `delivery` | `string[]` | where the payload enters: `query`, `path`, `body`, `header`, `cookie`, `referer`, `fragment`, `postmessage`, `window-name` |
| `reach` | derived | `server` if any delivery channel fits an HTTP request, `client` if the payload only exists browser-side, `unknown` if untriaged |
| `exploitable` | `bool` | `false` marks a deliberate control / true negative |
| `note` | `string?` | caveats: required user interaction, why it is a control, non-obvious parameter names |

`reach` is **derived**, not stored, so it can never contradict `delivery`.
`SERVER_CHANNELS` (`query path body header cookie referer`) is the single
place that definition lives.

### Classification rule

Classify by the **injection context** — where the bytes actually land — not by
what the receiving API does with a well-formed argument. A value the server
reflects raw into a JS string literal is `reflected-js` however inert the
function it is passed to, because the breakout happens before that function is
ever called. `dom` is for flows whose taint reaches a sink through client-side
code: either from a client-side source, or from a server-reflected literal
that a live DOM sink then executes without needing a breakout.

This rule is recorded in `Maze`'s doc comment so it does not drift.

### Backward compatibility

`Xssmaze.push` keeps its positional contract
(`name, url, desc, method, params`); the six new fields are optional keyword
args. All 1036 pre-existing call sites compile untouched, and the 838 that
were not triaged report `class: "unclassified"` / `reach: "unknown"` — which
is deliberately distinct from "reviewed and found safe".

### Also exposed

- `/map/json?vuln=`, `?reach=`, `?exploitable=` filters (compose with the
  existing `?type=` and `?q=`).
- `/map/markdown` gains `Class` / `Reach` / `Sources` / `Sinks` columns.
- `/map/categories` gains `exploitable`, `controls`, and per-category
  `classes` / `reach` histograms.
- `/stats` gains global `classes`, `reach`, `sources`, `sinks`, `exploitable`
  and `controls` rollups.
- README gets a "Vulnerability metadata" section.

### What got classified

All 198 endpoints in the 34 DOM-ish categories, plus the 23 new ones = 221.

```
dom                 160     reflected-attr       19     reflected-html   18
reflected-js         11     non-xss-control       6     prototype-pollution 4
csti                  3     unclassified        838
reach: server 201 · client 20 · unknown 838
```

### Mislabels this fixes

Each of these previously required reading the served HTML, and each was
mislabelled by the regex heuristic:

- **`fragment` and `sink` are not DOM categories.** They are server-side
  HTML/attribute reflections (option value, `<pre>`, `<svg><text>`,
  `<math><mi>`, details/summary, marquee; href / form-action / embed-src /
  link-href attributes). Now `reflected-html` / `reflected-attr` /
  `reflected-js`, each with a note saying the category name is misleading.
  `sink-level6` is the one genuine DOM flow in `sink` (`dataset` →
  `innerHTML`), and `sink-level8`'s injectable parameter is `callback`, not
  `query` — recorded in its note.
- **`prototype-pattern` is not prototype pollution.** Six framework-shaped
  server reflections (WordPress / PHP / ASP.NET / Angular-shaped /
  React-shaped / Jinja-shaped). Only `prototype-pollution-*` carries the
  `prototype-pollution` class, with the specific gadget key in each note
  (`html` → innerHTML, `src` → script src, `srcdoc` → iframe, `onInit` →
  `new Function`).
- **`mobserver-*` are MutationObserver re-entry cases**, not textContent
  sinks — each note names the re-entry shape.
- **`csti-level3` and `csti-level5` are not template evaluation.**
  `csti-level3` is Vue's `v-html` (an innerHTML sink) and `csti-level5` is
  jQuery `.html()`. Only levels 1, 2 and 4 are genuinely `csti`.
- **Fragment-only vs query-driven is now explicit.** 20 endpoints are
  `reach: "client"` — a request-only scanner physically cannot deliver a
  payload to them, so counting them as misses measures the wrong thing.

### Controls (`exploitable: false`) — 6 total

- **`xsleak-level1..5`** — cross-site *leak* oracles (response size, frame
  count, image load/error, timing, redirect-chain length). No injection sink
  exists; a scanner reporting nothing there is correct, not missing a bug.
  This is the case you called out explicitly.
- **`dom-level10`** — `img.src = query`. No modern browser executes a
  `javascript:` URL from an image src. Verified no-fire in Chrome 150 with
  both `javascript:alert(1)` and an HTML payload. Pure client-side flow with
  no server reflection anywhere, so the injection-context rule does not apply.

A spec enforces that every control carries an explanatory `note`, that
`non-xss-control` and `exploitable: false` stay in sync, that every classified
endpoint has a delivery channel, and that every `dom`-class endpoint has at
least one source and one sink.

### Existing documentation this corrected

Three levels were documented as protected/inert and are not. All three
re-verified in Chrome 150:

- **`dom-level9`** — *was* "non-exploitable in modern browsers". It executes.
  The inline `<script>` is empty, so prepare-a-script returned before setting
  the already-started flag; mutating its text re-runs prepare.
  (`?query=1` → no fire, `?query=alert(1)` → fires. Confirms the alert comes
  from the injected script text.)
- **`slot-level4`** — *was* "JSON-safe, no breakout (protected)".
  `query.to_json` does block a JS-string breakout, but the value still reaches
  `shadowRoot.innerHTML` as raw HTML and event handlers fire inside a shadow
  root.
- **`shadow-dom-level5`** — I initially got this one wrong in the same
  direction the old docs did, and it was caught in review. The value is
  reflected raw into the single-quoted JS string argument of
  `sheet.replaceSync('...')`, so `');alert(1)//` closes the string and runs
  code; `replaceSync`'s CSS-only semantics never come into play. Now
  `reflected-js` / exploitable.

`solutions/dom.md`, `solutions/slot.md`, `solutions/shadow-dom.md` and the
"intentionally hardened" list in `solutions/README.md` were all updated.

---

## Weakness 2 — new source / sink / propagation coverage

23 levels across three new categories. Absence was verified by grep before
writing each one. **Every level below was confirmed to fire in headless
Chrome 150** — there are no unsolvable levels.

### `domsource` (7) — sources nothing else in the lab reads

Sinks are deliberately boring (`innerHTML` / `insertAdjacentHTML` /
`document.write`) so results speak about the source, not the sink.

| Level | Source | Sink | Reach |
|-------|--------|------|-------|
| 1 | IndexedDB object store, read back through two async callbacks | `innerHTML` | server |
| 2 | `new URLSearchParams(location.hash.slice(1))` — fragment as its own querystring | `innerHTML` | client |
| 3 | `popstate` + `history.state` round-trip via `history.back()` | `insertAdjacentHTML` | server |
| 4 | `document.currentScript.src` — external script reads its own URL | `document.write` | server |
| 5 | sink reachable only inside a `navigator.permissions.query()` callback | `innerHTML` | server |
| 6 | CSS custom property round-tripped through the CSSOM | `insertAdjacentHTML` | client |
| 7 | **a real same-origin WebSocket** (`ws /domsource/level7/echo`) | `innerHTML` | server |

Level 1 persists to IndexedDB, so it keeps firing on later visits with no
parameter at all. Level 4 adds an unlisted helper route
(`/domsource/level4/boot.js`) in the same style as the existing
`/apidom/levelN/api` echoes. Level 7 is the first genuine WebSocket in the
repo — the existing `websocket-xss` and `stream` levels only dispatch
synthetic `MessageEvent`s, which their notes now say.

### `domsink` (8) — sinks nothing else in the lab reaches

The source is always a plain `location.search` read so results speak about the
sink.

| Level | Sink | Payload kind |
|-------|------|--------------|
| 1 | `document.implementation.createHTMLDocument` + `importNode` | HTML |
| 2 | `DOMParser.parseFromString` + `adoptNode` | HTML |
| 3 | indirect eval `(0, eval)(x)` | JavaScript |
| 4 | `Reflect.apply(eval, globalThis, [x])` | JavaScript |
| 5 | `Array.prototype.map(eval)` | JavaScript |
| 6 | `Object.assign(location, {href: x})` | `javascript:` URL |
| 7 | `setAttributeNS(null, 'onclick', x)` + programmatic click | JavaScript |
| 8 | `form.action = x` + `form.submit()` | `javascript:` URL |

Levels 1–2 launder through a document with no browsing context: the
`innerHTML` write is genuinely safe *where it happens*, and execution only
begins when the nodes are moved into the live document. A sink list that only
knows `innerHTML` sees nothing dangerous.

### `taintflow` (8) — propagation shapes, not new sinks

Every level is the same `location.*` → `innerHTML` flow with one laundering
step in between. Both ends are obvious; the question is whether the analyzer
still connects them.

1. `JSON.stringify` / `JSON.parse` round-trip
2. Proxy `get` trap *(fragment-driven)*
3. class getter
4. `async` / `await` (not `.then()`)
5. `Promise.all` result array, tainted element identified only by index
6. `structuredClone`
7. tagged template — the value never appears in the cooked strings *(fragment-driven)*
8. `String.prototype.replace` with a replacer function — the value is the
   callback's *return value*, never an argument to `replace()`

A tool that reports all eight has real dataflow. A tool that reports none is
matching `innerHTML =` against a literal `location.search` in the same
expression.

Each category has a `solutions/*.md` guide in the existing style, plus routing
specs.

---

## Deliberately skipped

- **Web Animations / CSS-injection-to-script-gadget** (from the candidate
  sink list). `element.animate()` cannot execute script, and CSS injection
  reaching script execution is not achievable in a modern browser without an
  additional framework gadget — it would have been an unsolvable level. The
  CSS-custom-property *source* half of that idea is covered by
  `domsource-level6`.
- **CSS custom property → `new Function`** — already exists at
  `modern-bypass` (`--custom-theme-color` → `new Function`). `domsource-level6`
  adds the distinct fragment-driven, HTML-sink variant rather than duplicating
  it.
- **Array `join`/`split` laundering** — already covered by `dom-level35`.
- **A real registered ServiceWorker** for `service-worker-level1/2`. SW
  registration is flaky on first load and in headless runs, which risks an
  intermittently unsolvable level. The existing levels keep their synthetic
  `MessageEvent`, and their notes now say so explicitly.
- **Cookie Store API (`cookieStore.get()`) as a source** — Chrome-only with no
  Firefox support, and `document.cookie` is already covered by `dom-level12`
  and `clientstate-level4`.
- **Re-verifying all 1036 pre-existing endpoints in a browser.** Only the
  disputed ones were probed. The rest were classified by reading the source,
  and the 838 untriaged endpoints are honestly marked `unclassified` rather
  than guessed at.
- **Fixing `sink-level8`'s `params` field** (it says `["query"]` but the
  injectable parameter is `callback`). Changing `params` would shift
  `/stats` and `/map/openapi` output for reasons unrelated to this work, so
  the correction is recorded in the endpoint's `note` instead.

## Known non-obvious constraints

- `domsource-level6` requires a payload that is a valid CSS declaration value:
  no quotes, no `;`, no `!`, balanced brackets. `<img src=x onerror=alert(1)>`
  qualifies. Documented in the level's `note` and in `solutions/domsource.md`.
- `domsink` payload kinds differ per level (HTML vs raw JS vs `javascript:`
  URL) — each level's `note` says which.
- 20 endpoints are `reach: "client"` and cannot be driven by a request-only
  scanner at all.
