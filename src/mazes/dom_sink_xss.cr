# DOM *sinks* the rest of the lab never exercises. The taint always arrives
# the same boring way (a `query` parameter read client-side off
# location.search) so that whatever a tool does or does not find here is a
# statement about the sink, not about the source.
#
# Two families:
#   - inert-document laundering: build the nodes in a document that has no
#     browsing context (createHTMLDocument / DOMParser), then move them into
#     the live one with importNode / adoptNode. Nothing executes until the
#     move, so a sink list that only knows `innerHTML` sees a safe write.
#   - non-obvious code-execution and navigation sinks: indirect eval,
#     Reflect.apply(eval), Array.prototype.map(eval), Object.assign onto
#     location, setAttributeNS, and form.action + submit().

# Level 1: document.implementation.createHTMLDocument + importNode.
# The markup is parsed into an inert document, so no resource loads and no
# handler fires until the imported copy is appended to the live document.
Xssmaze.push("domsink-level1", "/domsink/level1/?query=a", "createHTMLDocument + importNode moves inert nodes into the live document",
  vuln: "dom", sources: ["location.search"], sinks: ["createHTMLDocument", "importNode"], delivery: ["query"],
  note: "innerHTML is written to a document with no browsing context; execution happens on importNode + appendChild")
maze_get "/domsink/level1/" do |_env|
  "<html><body>
  <h1>Inert Document Import</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    // Parsed in a document with no browsing context: nothing runs here.
    var inert = document.implementation.createHTMLDocument('sandbox');
    inert.body.innerHTML = q;
    // ...but importing the nodes into the live document activates them.
    var imported = document.importNode(inert.body, true);
    while (imported.firstChild) {
      document.getElementById('out').appendChild(imported.firstChild);
    }
  </script>
  </body></html>"
end

# Level 2: DOMParser + adoptNode. Same shape as level 1, but the nodes are
# moved rather than copied, which some analyzers model differently.
Xssmaze.push("domsink-level2", "/domsink/level2/?query=a", "DOMParser + adoptNode moves parsed nodes into the live document",
  vuln: "dom", sources: ["location.search"], sinks: ["DOMParser", "adoptNode"], delivery: ["query"],
  note: "parsed in a detached document, then adopted node-by-node into the live one")
maze_get "/domsink/level2/" do |_env|
  "<html><body>
  <h1>Adopt Parsed Nodes</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var parsed = new DOMParser().parseFromString(q, 'text/html');
    var out = document.getElementById('out');
    while (parsed.body.firstChild) {
      out.appendChild(document.adoptNode(parsed.body.firstChild));
    }
  </script>
  </body></html>"
end

# Level 3: indirect eval. `(0, eval)(x)` evaluates in global scope and is a
# distinct call shape from a plain `eval(x)` reference.
Xssmaze.push("domsink-level3", "/domsink/level3/?query=a", "indirect eval (0, eval)(value) executes in global scope",
  vuln: "dom", sources: ["location.search"], sinks: ["indirect-eval"], delivery: ["query"],
  note: "payload is JavaScript, not HTML: (0, eval)(query)")
maze_get "/domsink/level3/" do |_env|
  "<html><body>
  <h1>Indirect Eval</h1>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    // Comma operator detaches eval from its reference: global-scope eval.
    if (q) { (0, eval)(q); }
  </script>
  </body></html>"
end

# Level 4: Reflect.apply(eval, ...). eval reached through the reflection API
# rather than by name.
Xssmaze.push("domsink-level4", "/domsink/level4/?query=a", "Reflect.apply(eval, globalThis, [value]) executes the value as JS",
  vuln: "dom", sources: ["location.search"], sinks: ["reflect-apply-eval"], delivery: ["query"],
  note: "payload is JavaScript, not HTML; eval is never called by name")
maze_get "/domsink/level4/" do |_env|
  "<html><body>
  <h1>Reflected Apply</h1>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    if (q) { Reflect.apply(eval, globalThis, [q]); }
  </script>
  </body></html>"
end

# Level 5: Array.prototype.map(eval). eval is passed as a callback, so it is
# never syntactically applied to the tainted value at all.
Xssmaze.push("domsink-level5", "/domsink/level5/?query=a", "Array.prototype.map(eval) evaluates each element as JS",
  vuln: "dom", sources: ["location.search"], sinks: ["array-map-eval"], delivery: ["query"],
  note: "payload is JavaScript; eval is handed to .map() as a callback and never appears in call position")
maze_get "/domsink/level5/" do |_env|
  "<html><body>
  <h1>Batch Runner</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    if (q) {
      // 'Run every configured step': eval as an iteratee.
      var results = q.split('\\n').map(eval);
      document.getElementById('out').textContent = 'ran ' + results.length + ' step(s)';
    }
  </script>
  </body></html>"
end

# Level 6: Object.assign onto the Location object. The href setter still
# fires, so a javascript: URL navigates and runs.
Xssmaze.push("domsink-level6", "/domsink/level6/?query=a", "Object.assign(location, {href: value}) triggers the href setter",
  vuln: "dom", sources: ["location.search"], sinks: ["object-assign-location", "location-nav"], delivery: ["query"],
  note: "payload is a javascript: URL; the navigation sink is an Object.assign target, not an assignment expression")
maze_get "/domsink/level6/" do |_env|
  "<html><body>
  <h1>Bulk Config Apply</h1>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    // Config-merge helper that happens to be handed the Location object.
    if (q) { Object.assign(location, { href: q }); }
  </script>
  </body></html>"
end

# Level 7: setAttributeNS. The namespaced setter installs an event-handler
# content attribute exactly like setAttribute does.
Xssmaze.push("domsink-level7", "/domsink/level7/?query=a", "setAttributeNS(null, 'onclick', value) installs an event handler",
  vuln: "dom", sources: ["location.search"], sinks: ["setAttributeNS", "event-handler-attribute"], delivery: ["query"],
  note: "payload is JavaScript; the button is clicked programmatically 150ms after load")
maze_get "/domsink/level7/" do |_env|
  "<html><body>
  <h1>Namespaced Attribute</h1>
  <button id='go'>Run action</button>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var btn = document.getElementById('go');
    if (q) {
      btn.setAttributeNS(null, 'onclick', q);
      setTimeout(function () { btn.click(); }, 150);
    }
  </script>
  </body></html>"
end

# Level 8: form.action + programmatic submit(). A javascript: action runs on
# submission — a navigation sink reached through the form API rather than
# through `location`.
Xssmaze.push("domsink-level8", "/domsink/level8/?query=a", "form.action set to a javascript: URL then submitted programmatically",
  vuln: "dom", sources: ["location.search"], sinks: ["form.action", "form-submit"], delivery: ["query"],
  note: "payload is a javascript: URL; form.submit() is called 150ms after load")
maze_get "/domsink/level8/" do |_env|
  "<html><body>
  <h1>Auto-Submit Form</h1>
  <form id='f' method='get'><input type='hidden' name='x' value='1'></form>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var form = document.getElementById('f');
    if (q) {
      form.action = q;
      setTimeout(function () { form.submit(); }, 150);
    }
  </script>
  </body></html>"
end
