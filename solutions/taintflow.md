# taintflow — solutions

Taint-*propagation* shapes, not new sources or sinks. Every level is the same
trivial flow — read a URL parameter, write it to `innerHTML` — with one
laundering step in between. Both ends are obvious; the question is whether an
analyzer still connects them once the value has been round-tripped through a
serializer, hidden behind a Proxy trap or an accessor, or carried across an
`await` / `Promise` boundary.

A tool that reports every level here has real dataflow. A tool that reports
none of them is pattern-matching `innerHTML =` against a literal
`location.search` in the same expression.

Payload for every level: `<img src=x onerror=alert(1)>`. All verified in
Chrome 150.

### taintflow-level1

`/taintflow/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `JSON.parse(JSON.stringify({body: query})).body` — the value leaves
  the JS heap as text and comes back as a different object before the sink.

### taintflow-level2

`/taintflow/level2/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: the value is wrapped in a `new Proxy(...)` whose `get` trap returns
  it. The property read that produces the taint is a function call on a
  handler object, not a property access on the store.

### taintflow-level3

`/taintflow/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the value is stashed on `this._value` in a class constructor and
  handed back out by a `get body()` accessor. The sink reads a property that
  is not the field the value was written to.

### taintflow-level4

`/taintflow/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the value crosses a microtask boundary through
  `await load(query)` inside an async IIFE — an `await`, not a `.then()`
  callback.

### taintflow-level5

`/taintflow/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: the value is the second element of a `Promise.all([...])` result
  array which is then `join('')`ed into the sink. The tainted element is
  identified only by its index.

### taintflow-level6

`/taintflow/level6/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `structuredClone({payload: {body: query}})` deep-copies the wrapper
  across the same serialization boundary `postMessage` uses, entirely
  in-process; the sink reads the copy.

### taintflow-level7

`/taintflow/level7/#%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>` (in the URL fragment)
- context: `` html`<article>${raw}</article>` `` — a tagged template. The
  value never appears in the literal's cooked strings; it arrives as a
  positional argument to the tag function, which concatenates it back in.

### taintflow-level8

`/taintflow/level8/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `template.replace('NAME_SLOT', function () { return query; })` —
  the value is the *return value* of a replacer callback. `replace()` itself
  never receives it as an argument.
