# Dynamic code / module execution DOM sinks. These are everyday patterns in
# modern apps — plugin/module loaders (dynamic import()), snippet runners and
# analytics/tag injectors (createElement('script') + .text/.src), and config-
# driven event binding (setAttribute('onclick', ...)). Each level isolates one
# JS-execution sink fed from a reflected param or a client-side source so the
# source -> sink flow is detectable by AST/DOM-aware scanners.

# Level 1: dynamic import() of a location.search value. A leading data: or
# https: specifier loads and runs an attacker-controlled ES module.
Xssmaze.push("codeexec-level1", "/codeexec/level1/?query=a", "dynamic import() of a location.search value (ESM module load)",
  vuln: "dom", sources: ["location.search"], sinks: ["dynamic-import"], delivery: ["query"])
maze_get "/codeexec/level1/" do |_env|
  "<html><body>
  <h1>Dynamic Module Loader</h1>
  <div id='status'>loading plugin...</div>
  <script>
    var name = new URLSearchParams(location.search).get('query') || '';
    if (name) {
      // Plugin system: dynamically import a module by user-provided URL.
      import(name).then(function () {
        document.getElementById('status').textContent = 'Plugin loaded';
      }).catch(function () {
        document.getElementById('status').textContent = 'Load failed';
      });
    }
  </script>
  </body></html>"
end

# Level 2: dynamic import() with a server-reflected specifier inlined into the
# import() call. A data: URL runs directly; a quote also breaks the JS string.
Xssmaze.push("codeexec-level2", "/codeexec/level2/?query=a", "dynamic import() with server-reflected module specifier",
  vuln: "dom", sources: ["server-reflected"], sinks: ["dynamic-import"], delivery: ["query"])
maze_get "/codeexec/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Module Loader</h1>
  <div id='status'>resolving module...</div>
  <script>
    // Server inlines the configured module path into the import() call.
    import('#{query}').then(function () {
      document.getElementById('status').textContent = 'Module ready';
    }).catch(function () {});
  </script>
  </body></html>"
end

# Level 3: inline <script> body taken from location.hash. Assigning to
# script.text and appending the element executes the code as JavaScript.
Xssmaze.push("codeexec-level3", "/codeexec/level3/", "inline script element text from location.hash (createElement+append)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["script.text"], delivery: ["fragment"])
maze_get "/codeexec/level3/" do |_env|
  "<html><body>
  <h1>Hash Script Runner</h1>
  <div id='out'>idle</div>
  <script>
    var code = decodeURIComponent(location.hash.slice(1));
    if (code) {
      var s = document.createElement('script');
      s.text = code; // inline script body -> executes on append
      document.body.appendChild(s);
    }
  </script>
  </body></html>"
end

# Level 4: server-reflected snippet assigned to an inline script element body.
# The reflected value becomes the script source text and runs verbatim.
Xssmaze.push("codeexec-level4", "/codeexec/level4/?query=a", "server-reflected text injected into an inline script element",
  vuln: "dom", sources: ["server-reflected"], sinks: ["script.text"], delivery: ["query"])
maze_get "/codeexec/level4/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Snippet Runner</h1>
  <script>
    var snippet = '#{query}';
    var s = document.createElement('script');
    s.text = snippet; // user snippet becomes an inline script body
    document.body.appendChild(s);
  </script>
  </body></html>"
end

# Level 5: DOM event-handler attribute set from a reflected value via
# setAttribute('onclick', ...). Programmatically clicking fires the handler.
Xssmaze.push("codeexec-level5", "/codeexec/level5/?query=a", "DOM event-handler attribute set via setAttribute('onclick', ...)",
  vuln: "dom", sources: ["server-reflected"], sinks: ["setAttribute", "event-handler-attribute"], delivery: ["query"], note: "the handler is fired programmatically 200ms after load")
maze_get "/codeexec/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Action Button</h1>
  <button id='action'>Run action</button>
  <script>
    // Bind a handler from the (reflected) config, then trigger it.
    var action = '#{query}';
    var btn = document.getElementById('action');
    btn.setAttribute('onclick', action);
    setTimeout(function () { btn.click(); }, 200);
  </script>
  </body></html>"
end

# Level 6: dynamic external script whose src comes from a reflected value.
# An attacker-controlled URL (//host/x.js or data:) loads and runs as script.
Xssmaze.push("codeexec-level6", "/codeexec/level6/?query=a", "dynamic external script src from reflected value",
  vuln: "dom", sources: ["server-reflected"], sinks: ["script.src"], delivery: ["query"])
maze_get "/codeexec/level6/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Tag Loader</h1>
  <div id='status'>loading tag...</div>
  <script>
    // Analytics/tag loader: build a <script src> from the configured URL.
    var src = '#{query}';
    var s = document.createElement('script');
    s.src = src;
    document.body.appendChild(s);
  </script>
  </body></html>"
end
