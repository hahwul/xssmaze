require "html"

# Global session-like store for Level 1 Multi-Step XSS
level1_store = Hash(String, String).new

# Level 1: Multi-Step / Multi-State Session-Locked Stored XSS
# DAST scanners scan endpoints in isolation and do not track states across distinct HTTP methods/pages.
Xssmaze.push("modern-bypass-level1", "/modern-bypass/level1/preview?view=draft", "Session-locked multi-step draft preview", "GET", ["view"])

# Step 1: Endpoint to save draft (POST)
maze_post "/modern-bypass/level1/save" do |env|
  # Use simple time-based and random generator to construct a session_id if cookie not present
  session_id = env.request.cookies["session_id"]?.try(&.value) || (Time.utc.to_unix_ms.to_s + "_" + Random.rand(100000).to_s)
  env.response.cookies << HTTP::Cookie.new("session_id", session_id, path: "/modern-bypass/level1/")

  content = env.params.body["content"]? || ""
  level1_store[session_id] = content

  env.response.content_type = "application/json"
  {status: "success", message: "Draft saved successfully!"}.to_json
end

# Step 2: Endpoint to preview draft (GET)
maze_get "/modern-bypass/level1/preview" do |env|
  session_id = env.request.cookies["session_id"]?.try(&.value)
  view = env.params.query["view"]?

  if session_id && view == "draft" && level1_store.has_key?(session_id)
    draft = level1_store[session_id]
    "<!doctype html><html><head><title>Draft Preview</title></head><body>
    <h1>Draft Preview</h1>
    <div class='preview-container'>#{draft}</div>
    </body></html>"
  else
    "<!doctype html><html><head><title>Draft Editor</title></head><body>
    <h1>Draft Editor</h1>
    <p>No active draft found or invalid view mode.</p>
    <form action='/modern-bypass/level1/save' method='post'>
      <textarea name='content' placeholder='Write your draft here...' style='width: 300px; height: 100px;'></textarea><br>
      <button type='submit'>Save Draft</button>
    </form>
    </body></html>"
  end
end


# Level 2: DOM Clobbering to XSS via Global Config Override
# Scanners lack the static/dynamic tracing engines to detect when a reflected attribute
# overrides global namespaces, which are subsequently loaded into dynamic script tags.
Xssmaze.push("modern-bypass-level2", "/modern-bypass/level2/?query=a", "DOM Clobbering XSS via global config override", "GET", ["query"])
maze_get "/modern-bypass/level2/" do |env|
  query = env.params.query.fetch("query", "")

  # Strip standard tag vectors and event handlers but keep anchor tags, ids, names, and hrefs intact!
  sanitized = query.gsub(/<(script|iframe|object|embed)[^>]*>([\s\S]*?)<\/\1>/i, "")
                   .gsub(/<\/?(script|iframe|object|embed)[^>]*>/i, "")
                   .gsub(/\bon[a-z]+=/i, "data-blocked-event=")

  "<!doctype html><html><head><title>Profile Page</title></head><body>
  <h1>User Profile</h1>
  <div class='user-bio'>#{sanitized}</div>

  <script>
    // Vulnerable fallback: if window.config is clobbered by an injected element
    // like <a id='config' href='data:text/javascript,alert(1)'>, the browser resolves config
    // to that HTMLAnchorElement and evaluates config.href as the URL.
    var config = window.config || { api_endpoint: '/api/v1/status' };

    setTimeout(function() {
      var endpoint = config.api_endpoint || config.href;
      if (endpoint) {
        var s = document.createElement('script');
        s.src = endpoint;
        document.body.appendChild(s);
      }
    }, 500);
  </script>
  </body></html>"
end


# Level 3: Vue.js Client-Side Template Injection (CSTI) Bypassing Tag Filters
# Scanners check for HTML injection by looking for tags like <script> or <img onerror>.
# Stripping `<` and `>` bypasses these scanners completely while Vue parses curly braces.
Xssmaze.push("modern-bypass-level3", "/modern-bypass/level3/?query=a", "Vue.js Client-Side Template Injection (CSTI) bypassing tag filters", "GET", ["query"])
maze_get "/modern-bypass/level3/" do |env|
  query = env.params.query.fetch("query", "")

  # Strip angle brackets entirely - no HTML tags whatsoever!
  sanitized = query.gsub("<", "").gsub(">", "")

  "<!doctype html><html><head>
  <title>Search Catalog</title>
  <script src='https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.js'></script>
  </head><body>
  <div id='app'>
    <h1>Product Catalog</h1>
    <p>Search results for: #{sanitized}</p>
  </div>

  <script>
    new Vue({
      el: '#app',
      data: {}
    });
  </script>
  </body></html>"
end


# Level 4: Client-Side JavaScript Prototype Pollution to DOM XSS
# Scanners do not test dynamic client-side hash parsing (#) or prototype poisoning.
Xssmaze.push("modern-bypass-level4", %q{/modern-bypass/level4/#{"__proto__":{"scriptUrl":"data:text/javascript,alert(1)"}}}, "Client-side Prototype Pollution to DOM XSS via hash parsing", "GET", [] of String)
maze_get "/modern-bypass/level4/" do |env|
  "<!doctype html><html><head><title>Dashboard</title></head><body>
  <h1>Modern Dashboard</h1>
  <div id='output'>Initializing theme...</div>

  <script>
    function merge(target, source) {
      for (let key in source) {
        if (typeof target[key] === 'object' && typeof source[key] === 'object') {
          merge(target[key], source[key]);
        } else {
          target[key] = source[key];
        }
      }
    }

    function parseHashConfig() {
      var obj = {};
      var hash = window.location.hash.substring(1);
      if (hash) {
        try {
          var parsed = JSON.parse(decodeURIComponent(hash));
          merge(obj, parsed);
        } catch(e) {
          console.error('Invalid hash config', e);
        }
      }
      return obj;
    }

    setTimeout(function() {
      var config = parseHashConfig();
      var settings = {};

      // If settings.scriptUrl is polluted via Object.prototype
      var scriptUrl = settings.scriptUrl;
      if (scriptUrl) {
        var s = document.createElement('script');
        s.src = scriptUrl;
        document.body.appendChild(s);
        document.getElementById('output').textContent = 'Loaded plugin from ' + scriptUrl;
      } else {
        document.getElementById('output').textContent = 'Default theme loaded (blue).';
      }
    }, 500);
  </script>
  </body></html>"
end


# Level 5: SVG Content-Type Reflection with Script Tag Stripping
# Scanners assume SVG is safe when `<script>` is deleted, ignoring element-level event triggers like `<svg onload="...">`.
Xssmaze.push("modern-bypass-level5", "/modern-bypass/level5/?svg=a", "SVG reflection with script tag stripping (requires direct navigation)", "GET", ["svg"])
maze_get "/modern-bypass/level5/" do |env|
  svg = env.params.query.fetch("svg", "")

  # Strip script tags recursively
  sanitized = svg.gsub(/<script[^>]*>([\s\S]*?)<\/script>/i, "")
                 .gsub(/<\/?script[^>]*>/i, "")

  env.response.content_type = "image/svg+xml"
  sanitized
end


# Level 6: Entity Decoding inside Iframe `srcdoc` Attribute Context
# Scanners check if `<script>` is escaped to `&lt;script&gt;` and report safe.
# They miss that the browser decodes attribute entities inside `srcdoc` before parsing the frame HTML.
Xssmaze.push("modern-bypass-level6", "/modern-bypass/level6/?query=a", "Iframe srcdoc attribute entity decoding bypass", "GET", ["query"])
maze_get "/modern-bypass/level6/" do |env|
  query = env.params.query.fetch("query", "")

  # Escapes all special characters - safe on a standard page body,
  # but behaves dangerously inside an iframe's srcdoc attribute!
  escaped_query = HTML.escape(query)

  "<!doctype html><html><head><title>Preview Sandbox</title></head><body>
  <h1>Safe Preview Sandbox</h1>
  <p>Rendering content inside a secure iframe sandbox...</p>

  <!-- HTML-escaped content is placed directly in srcdoc. The browser decodes &lt; to < before parsing. -->
  <iframe srcdoc=\"#{escaped_query}\" style='border: 1px solid #ccc; width: 400px; height: 200px;'></iframe>
  </body></html>"
end


# Level 7: Unicode Normalization (NFKC) Filter Bypass
# DAST scanners rarely send Unicode homoglyphs to check normalization side-effects.
Xssmaze.push("modern-bypass-level7", "/modern-bypass/level7/?query=a", "Unicode normalization (NFKC) filter bypass", "GET", ["query"])
maze_get "/modern-bypass/level7/" do |env|
  query = env.params.query.fetch("query", "")

  # WAF blocks standard keywords
  if query.match(/<script|onload|onerror|onfocus/i)
    halt env, status_code: 403, response: "WAF Blocked: Dangerous keywords detected!"
  end

  "<!doctype html><html><head><title>Unicode Search</title></head><body>
  <h1>Unicode Search</h1>
  <div id='output'></div>

  <script>
    var raw = '#{query}';

    // Bypasses the backend filter since characters were Unicode homoglyphs,
    // but normalizes to ASCII HTML on the client-side. E.g., ＜ｓｃｒｉｐｔ＞ or Kelvin sign.
    var normalized = raw.normalize('NFKC');

    document.getElementById('output').innerHTML = 'Normalized results: ' + normalized;
  </script>
  </body></html>"
end


# Level 8: Flawed Regex Host Whitelist for Dynamic Scripts
# Scanners do not test subdomain/credential validation bypasses of whitelist patterns.
Xssmaze.push("modern-bypass-level8", "/modern-bypass/level8/?callback_url=https://xssmaze.com/js/callback.js", "Flawed regex domain whitelist bypass for dynamic scripts", "GET", ["callback_url"])
maze_get "/modern-bypass/level8/" do |env|
  url = env.params.query.fetch("callback_url", "https://xssmaze.com/js/callback.js")

  # Flawed domain whitelist check
  # Intended to only allow script URLs starting with xssmaze.com
  # Bypassed via: https://xssmaze.com.attacker.com/malicious.js
  is_safe = url.match(/^https?:\/\/xssmaze\.com/i)

  "<!doctype html><html><head><title>Callback Loader</title></head><body>
  <h1>Dynamic Callback Loader</h1>
  <div id='status'></div>

  <script>
    var isSafe = #{is_safe ? "true" : "false"};
    var url = '#{url}';

    if (isSafe) {
      var s = document.createElement('script');
      s.src = url;
      document.body.appendChild(s);
      document.getElementById('status').textContent = 'Loading script from: ' + url;
    } else {
      document.getElementById('status').textContent = 'Blocked unsafe script URL!';
    }
  </script>
  </body></html>"
end
