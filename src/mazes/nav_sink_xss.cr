# Navigation sinks: a tainted value reaches a navigation API as a URL, and a
# `javascript:` scheme there executes script. These are everyday patterns —
# "open in new tab" (window.open), "continue to ..." / post-login redirects
# (location.assign), and SPA bounce/replace flows (location.replace) — and
# each isolates one navigation sink fed from a DOM source or a reflected
# param. Note these are the *method* / window forms; plain `location.href =`
# assignment lives in the `dom` category. A DOM-aware scanner should model the
# argument-0 URL position of window.open / location.assign / location.replace
# as a sink, exactly as it does a `location` assignment.

# Level 1: window.open(location.hash) — "open in new tab" helper. A
# javascript: fragment runs in the freshly opened window.
Xssmaze.push("navsink-level1", "/navsink/level1/", "window.open() of location.hash (javascript: scheme)", "GET", ["#hash"])
maze_get "/navsink/level1/" do |_env|
  "<html><body>
  <h1>Open Link</h1>
  <script>
    var target = decodeURIComponent(location.hash.slice(1));
    // No scheme validation: javascript: executes in the opened window.
    if (target) { window.open(target); }
  </script>
  </body></html>"
end

# Level 2: window.open() of a location.search value.
Xssmaze.push("navsink-level2", "/navsink/level2/?query=a", "window.open() of a location.search value (javascript: scheme)")
maze_get "/navsink/level2/" do |_env|
  "<html><body>
  <h1>Preview</h1>
  <script>
    var url = new URLSearchParams(location.search).get('query') || '';
    if (url) { window.open(url, '_blank'); }
  </script>
  </body></html>"
end

# Level 3: location.assign() — the method form of a same-frame navigation.
# A javascript: URL executes in the current document.
Xssmaze.push("navsink-level3", "/navsink/level3/?query=a", "location.assign() of a location.search value (javascript: scheme)")
maze_get "/navsink/level3/" do |_env|
  "<html><body>
  <h1>Redirecting...</h1>
  <script>
    var next = new URLSearchParams(location.search).get('query') || '';
    // 'Continue to ...' redirect: assign() runs a javascript: URL in-frame.
    if (next) { location.assign(next); }
  </script>
  </body></html>"
end

# Level 4: location.replace() of location.hash — SPA bounce/replace flow.
Xssmaze.push("navsink-level4", "/navsink/level4/", "location.replace() of location.hash (javascript: scheme)", "GET", ["#hash"])
maze_get "/navsink/level4/" do |_env|
  "<html><body>
  <h1>Loading route...</h1>
  <script>
    var route = decodeURIComponent(location.hash.slice(1));
    if (route) { location.replace(route); }
  </script>
  </body></html>"
end

# Level 5: window.open() with a server-reflected URL inlined into a JS string.
# The reflection is visible in the served HTML source.
Xssmaze.push("navsink-level5", "/navsink/level5/?query=a", "server-reflected URL passed to window.open()")
maze_get "/navsink/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Launch</h1>
  <script>
    var url = '#{query}';
    window.open(url);
  </script>
  </body></html>"
end

# Level 6: location.assign() with a server-reflected URL inlined into a JS
# string.
Xssmaze.push("navsink-level6", "/navsink/level6/?query=a", "server-reflected URL passed to location.assign()")
maze_get "/navsink/level6/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Go</h1>
  <script>
    var dest = '#{query}';
    location.assign(dest);
  </script>
  </body></html>"
end
