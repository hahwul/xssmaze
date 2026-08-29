require "html"

# Global session-like store for Level 1 Multi-Step XSS
level1_store = Hash(String, String).new

# Level 1: Multi-Step / Multi-State Session-Locked Stored XSS
# DAST scanners scan endpoints in isolation and do not track states across distinct HTTP methods/pages.
Xssmaze.push("modern-bypass-level1", "/modern-bypass/level1/preview?view=draft", "Session-locked multi-step draft preview", "GET", ["view"],
  vuln: "stored", delivery: ["body"], note: "the payload enters as the content field of POST /modern-bypass/level1/save; this preview only renders it when the session_id cookie set by that POST is replayed together with view=draft")

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
Xssmaze.push("modern-bypass-level2", "/modern-bypass/level2/?query=a", "DOM Clobbering XSS via global config override", "GET", ["query"],
  vuln: "dom", sources: ["server-reflected"], sinks: ["script.src"], delivery: ["query"], note: "script/iframe/object/embed tags and on*= handlers are all stripped, so nothing executes directly; the surviving path is DOM clobbering with <a id=config href=data:text/javascript,alert(1)>, which window.config resolves to and the page loads as a script 500ms later")
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
Xssmaze.push("modern-bypass-level3", "/modern-bypass/level3/?query=a", "Vue.js Client-Side Template Injection (CSTI) bypassing tag filters", "GET", ["query"],
  vuln: "csti", delivery: ["query"], note: "Vue 2 compiles #app as a template and angle brackets are stripped, so the payload is a {{ }} expression; needs the jsdelivr CDN to be reachable")
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
Xssmaze.push("modern-bypass-level4", %q(/modern-bypass/level4/#{"__proto__":{"scriptUrl":"data:text/javascript,alert(1)"}}), "Client-side Prototype Pollution to DOM XSS via hash parsing", "GET", [] of String,
  vuln: "prototype-pollution", sources: ["location.hash"], sinks: ["script.src"], delivery: ["fragment"], note: "fragment only, so no request-only scanner can deliver it; the hash is JSON.parsed and merged, and the polluted scriptUrl key becomes the src of a dynamically created <script>")
maze_get "/modern-bypass/level4/" do |_env|
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
Xssmaze.push("modern-bypass-level5", "/modern-bypass/level5/?svg=a", "SVG reflection with script tag stripping (requires direct navigation)", "GET", ["svg"],
  vuln: "reflected-html", delivery: ["query"], note: "the parameter is svg, not query; the response is served as image/svg+xml, so it only executes on direct navigation, and only <script> is stripped, leaving <svg onload=alert(1)>")
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
Xssmaze.push("modern-bypass-level6", "/modern-bypass/level6/?query=a", "Iframe srcdoc attribute entity decoding bypass", "GET", ["query"],
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "entity-encoded in the outer document but decoded again when srcdoc is parsed")
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
Xssmaze.push("modern-bypass-level7", "/modern-bypass/level7/?query=a", "Unicode normalization (NFKC) filter bypass", "GET", ["query"],
  vuln: "reflected-js", sinks: ["innerHTML"], delivery: ["query"], note: "the keyword WAF (403) never looks at quotes, so the single-quoted JS string can simply be closed; the intended path is a fullwidth homoglyph payload that NFKC-normalises into real markup before innerHTML")
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
Xssmaze.push("modern-bypass-level8", "/modern-bypass/level8/?callback_url=https://xssmaze.com/js/callback.js", "Flawed regex domain whitelist bypass for dynamic scripts", "GET", ["callback_url"],
  vuln: "reflected-js", sinks: ["script.src"], delivery: ["query"], note: "the parameter is callback_url; it lands raw in a single-quoted JS string, so it runs whatever the whitelist decides. The intended bug is the unanchored host regex, which https://xssmaze.com.attacker.com/x.js satisfies")
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

# Level 9: Event Handler in an Unquoted Attribute Context with Space Stripping (Requires Slash Delimiter)
# Scanners check if they can inject attribute event handlers using alternative separators like `/` when spaces are stripped.
Xssmaze.push("modern-bypass-level9", "/modern-bypass/level9/?query=a", "Event handler unquoted attribute with space stripping (requires slash separator)", "GET", ["query"],
  vuln: "reflected-attr", delivery: ["query"], note: "all whitespace is stripped, so a multi-attribute payload needs slash separators; the template already supplies the leading space, so onerror=alert(1) alone fires on the broken img")
maze_get "/modern-bypass/level9/" do |env|
  query = env.params.query.fetch("query", "")

  # Strip ALL whitespace!
  sanitized = query.gsub(/\s+/, "")

  "<!doctype html><html><head><title>Unquoted Attribute</title></head><body>
  <h1>Search Profile</h1>
  <img src=x class=avatar title=user_profile #{sanitized}>
  </body></html>"
end

# Level 10: Tag Injection in Nested <select> and <option> Elements
# Tests if the scanner can properly identify single-quoted option attributes inside select contexts.
Xssmaze.push("modern-bypass-level10", "/modern-bypass/level10/?query=a", "Nested select option attribute tag breakout", "GET", ["query"],
  vuln: "reflected-attr", delivery: ["query"], note: "double quotes are encoded and the option value is single-quoted; the parser is in in-select mode, so close </select> before injecting anything other than <script>")
maze_get "/modern-bypass/level10/" do |env|
  query = env.params.query.fetch("query", "")

  # Escapes double quotes inside option value attribute, but single quotes are unescaped
  escaped = query.gsub("\"", "&quot;")

  "<!doctype html><html><head><title>Drop-down Menu</title></head><body>
  <h1>Select Option</h1>
  <form>
    <select name='theme'>
      <option value='#{escaped}'>Custom Theme</option>
    </select>
  </form>
  </body></html>"
end

# Level 11: Style Context with Dynamic CSS Variable to JS Execution
# The user parameter is reflected inside a style block. Scanners trying to close style tags are blocked by WAF.
# Scanners must understand the style evaluates inside a CSS variable as plain JS by the page scripts.
Xssmaze.push("modern-bypass-level11", "/modern-bypass/level11/?query=a", "Style context CSS variable to dynamic JS execution", "GET", ["query"],
  vuln: "dom", sources: ["css-custom-property"], sinks: ["Function"], delivery: ["query"], note: "closing </style> is answered with 403, so no markup is involved at all: the CSS custom property value is read back and passed to new Function 500ms after load, making the payload plain JS such as alert(1)")
maze_get "/modern-bypass/level11/" do |env|
  query = env.params.query.fetch("query", "")

  # Block style close tags to force CSS-native execution
  if query.match(/<\/style/i)
    halt env, status_code: 403, response: "WAF Blocked: Style close tag detected!"
  end

  "<!doctype html><html><head><title>Custom Style</title>
  <style>
    body {
      --custom-theme-color: #{query};
    }
  </style>
  </head><body>
  <h1>Custom Styling</h1>
  <div id='output'>Evaluating custom styles...</div>

  <script>
    setTimeout(function() {
      // Dynamic engine parses custom styles and evaluates them (e.g. for custom JS theme scripting)
      var style = getComputedStyle(document.body);
      var payload = style.getPropertyValue('--custom-theme-color').trim();
      if (payload) {
        try {
          var f = new Function(payload);
          f();
        } catch(e) {
          console.error('Theme script error', e);
        }
      }
    }, 500);
  </script>
  </body></html>"
end

# Level 12: Content Security Policy (CSP) Bypass using JSONP Whitelisted Origin
# Restricts script-src to self and googleapis. Users can bypass CSP using JSONP callback dynamically.
Xssmaze.push("modern-bypass-level12", "/modern-bypass/level12/?query=a", "CSP bypass via Whitelisted JSONP API Endpoint", "GET", ["query"],
  vuln: "reflected-attr", delivery: ["query"], note: "the value lands in a single-quoted <script src> in <head>, but the CSP blocks inline script, so an inline breakout does not run; the bypass is to load a template-engine gadget from the whitelisted ajax.googleapis.com. The jquery.min.js callback parameter is not a real JSONP endpoint")
maze_get "/modern-bypass/level12/" do |env|
  query = env.params.query.fetch("query", "")

  # Restrict script-src to self and googleapis
  env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' https://ajax.googleapis.com; object-src 'none';"

  # The application reflects user query inside the script URL callback
  "<!doctype html><html><head><title>Whitelisted Library Loader</title>
  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js?callback=#{query}'></script>
  </head><body>
  <h1>Library Loader</h1>
  <p>Loading whitelist library with callback parameter...</p>
  </body></html>"
end

# Level 13: SVG Path Attribute Custom Trigger Injection
# Measures if the scanner can detect XSS in custom data attributes or SVG sub-properties.
Xssmaze.push("modern-bypass-level13", "/modern-bypass/level13/?query=a", "SVG Path custom action trigger XSS", "GET", ["query"],
  vuln: "reflected-attr", sinks: ["eval"], delivery: ["query"], note: "the single-quoted SVG path d attribute can be broken out of, but no breakout is needed: any d value containing xss: has the rest eval-ed 500ms after load, so xss:alert(1) is enough")
maze_get "/modern-bypass/level13/" do |env|
  query = env.params.query.fetch("query", "")

  "<!doctype html><html><head><title>Vector Viewer</title></head><body>
  <h1>SVG Path Viewer</h1>
  <svg width='100' height='100'>
    <path id='my-path' d='#{query}' fill='none' stroke='black'/>
  </svg>

  <script>
    setTimeout(function() {
      var path = document.getElementById('my-path');
      if (path) {
        var d = path.getAttribute('d');
        if (d && d.indexOf('xss:') !== -1) {
          var code = d.split('xss:')[1];
          eval(code);
        }
      }
    }, 500);
  </script>
  </body></html>"
end

# Level 14: Strict Event Denylist (Requires Obscure Event Handlers)
# Blocks the 10 most common event handlers. Scanner must utilize obscure events like pointerover or pointerdown.
Xssmaze.push("modern-bypass-level14", "/modern-bypass/level14/?query=a", "Strict event denylist (requires obscure HTML5 events)", "GET", ["query"],
  vuln: "reflected-attr", delivery: ["query"], note: "ten common handlers are answered with 403; obscure ones are not, so break out of the double-quoted title with <details open ontoggle=alert(1)>")
maze_get "/modern-bypass/level14/" do |env|
  query = env.params.query.fetch("query", "")

  # Block common events
  if query.match(/onload|onerror|onclick|onmouseover|onfocus|onblur|onchange|onkeydown|onkeypress|onkeyup/i)
    halt env, status_code: 403, response: "WAF Blocked: Common event handler detected!"
  end

  "<!doctype html><html><head><title>Obscure Events</title></head><body>
  <h1>Profile Feed</h1>
  <div title=\"#{query}\">Hover or scroll to trigger events...</div>
  </body></html>"
end

# Level 15: Nested JSON String in Single-Quoted Attribute Context
# Replaces double quotes but leaves single quotes intact. Breakout via single-quote attribute boundary.
Xssmaze.push("modern-bypass-level15", "/modern-bypass/level15/?query=a", "Nested JSON inside single-quoted attribute breakout", "GET", ["query"],
  vuln: "reflected-attr", sinks: ["innerHTML"], delivery: ["query"], note: "only double quotes are escaped, so a single quote leaves the data-info attribute; alternatively the JSON name member reaches document.body.innerHTML, so a quote-free payload works with no breakout at all")
maze_get "/modern-bypass/level15/" do |env|
  query = env.params.query.fetch("query", "")

  # Naive escaping: replaces double quotes but leaves single quotes intact!
  escaped = query.gsub("\"", "\\\"")

  "<!doctype html><html><head><title>JSON data attribute</title></head><body>
  <h1>User Profile</h1>
  <div id='user' data-info='{\"name\": \"#{escaped}\"}'>Hover for metadata</div>

  <script>
    var el = document.getElementById('user');
    var info = JSON.parse(el.getAttribute('data-info'));
    // Dangerous innerHTML assignment of JSON attribute property
    document.body.innerHTML += '<div>Loaded user: ' + info.name + '</div>';
  </script>
  </body></html>"
end

# Level 16: Multi-Context Variable Splitting XSS
# First reflection is fully HTML-escaped. Second reflection is unquoted raw JS.
Xssmaze.push("modern-bypass-level16", "/modern-bypass/level16/?query=a", "Multi-context unquoted JS variable splitting", "GET", ["query"],
  vuln: "reflected-js", delivery: ["query"], note: "the first reflection is HTML-escaped; the second is an unquoted JS value, so the payload is a bare expression such as alert(1)")
maze_get "/modern-bypass/level16/" do |env|
  query = env.params.query.fetch("query", "")

  "<!doctype html><html><head><title>Multi-Context</title></head><body>
  <h1>Workspace Settings</h1>

  <script>
    // Double reflection: first is single-quoted JS variable
    var configName = '#{HTML.escape(query)}';

    // Second is unquoted raw reflection
    var configId = #{query};
  </script>
  </body></html>"
end

# Level 17: Shadow DOM (Closed Root) Reflection via Client-Side Query Parsing
# Static HTML response contains no user input; the sink is reached only after JS execution.
# Many crawlers and simple DAST tools won't execute JS or inspect closed shadow roots.
Xssmaze.push("modern-bypass-level17", "/modern-bypass/level17/?query=a", "Closed ShadowRoot innerHTML reflection via URLSearchParams (client-side only)", "GET", ["query"],
  vuln: "dom", sources: ["location.search"], sinks: ["attachShadow.innerHTML"], delivery: ["query"], note: "the server response carries no reflection at all, and the shadow root is closed, so the injected node is invisible to document queries")
maze_get "/modern-bypass/level17/" do |_env|
  "<!doctype html><html><head><meta charset='utf-8'><title>Shadow DOM (closed) Reflection</title></head><body>
  <h1>Modern Bypass Level 17</h1>
  <p>This page reads <code>?query=...</code> on the client and injects it into a <strong>closed</strong> ShadowRoot via <code>innerHTML</code>.</p>
  <div id='host'></div>

  <script>
    const params = new URLSearchParams(window.location.search);
    const input = params.get('query') || '';

    const el = document.getElementById('host');
    const shadowRoot = el.attachShadow({mode: 'closed'});
    shadowRoot.innerHTML = '<div>Reflected: ' + input + '</div>';
  </script>
  </body></html>"
end

# Level 18: Closed ShadowRoot + Slot-Based Injection
# The shadow DOM uses a slot, while the light DOM is populated via client-side innerHTML.
Xssmaze.push("modern-bypass-level18", "/modern-bypass/level18/?query=a", "Closed ShadowRoot slot renders light DOM populated via client-side innerHTML", "GET", ["query"],
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"], note: "the server response carries no reflection at all; innerHTML does not run a bare <script>, so use <img src=x onerror=...>")
maze_get "/modern-bypass/level18/" do |_env|
  "<!doctype html><html><head><meta charset='utf-8'><title>Shadow DOM Slot (closed)</title></head><body>
  <h1>Modern Bypass Level 18</h1>
  <p>Client-side code writes <code>?query=...</code> into the host's light DOM using <code>innerHTML</code>; a <strong>closed</strong> ShadowRoot renders it via <code>&lt;slot&gt;</code>.</p>
  <div id='host'></div>

  <script>
    const params = new URLSearchParams(window.location.search);
    const input = params.get('query') || '';

    const host = document.getElementById('host');
    const shadowRoot = host.attachShadow({mode: 'closed'});
    shadowRoot.innerHTML = '<div>Slotted content:</div><div class=\"slot-wrap\"><slot></slot></div>';

    // Light DOM injection that becomes visible inside the closed shadow root via slotting.
    host.innerHTML = input;
  </script>
  </body></html>"
end

# Level 19: Web Messaging (postMessage) Origin RegExp Bypass
# Evaluates event data from postMessage listeners where origin validation has weak unanchored RegExp.
Xssmaze.push("modern-bypass-level19", "/modern-bypass/level19/", "Web Messaging (postMessage) origin RegExp bypass", "GET", [] of String,
  vuln: "dom", sources: ["postMessage"], sinks: ["eval"], delivery: ["postmessage"], note: "needs a real browser: the payload is a postMessage, so a request-only scanner cannot deliver it. The origin check is an unanchored RegExp, so any origin merely containing `https://xssmaze.com` passes — `https://xssmaze.com.attacker.com` is the intended bypass")
maze_get "/modern-bypass/level19/" do |_env|
  "<!doctype html><html><head><meta charset='utf-8'><title>PostMessage Portal</title></head><body>
  <h1>Modern Bypass Level 19</h1>
  <p>This portal communicates with parent frames. It securely executes actions sent via <code>postMessage</code>, verifying the sender's origin is <code>xssmaze.com</code>.</p>
  <div id='output'>Awaiting handshake...</div>

  <script>
    window.addEventListener('message', function(event) {
      // Weak origin validation: unanchored RegExp allowing domains like https://xssmaze.com.attacker.com
      if (/https:\\/\\/xssmaze.com/.test(event.origin)) {
        var data = event.data;
        if (data && data.action === 'execute') {
          // Dynamic execution of message payload code
          try {
            eval(data.code);
            document.getElementById('output').textContent = 'Executed dynamic task!';
          } catch (e) {
            document.getElementById('output').textContent = 'Error executing task: ' + e.message;
          }
        }
      } else {
        console.warn('Blocked message from unauthorized origin:', event.origin);
      }
    });
  </script>
  </body></html>"
end

# Level 20: Double URL Decoding / Double Escape Bypass
# The application uses explicit second URL decoding after passing input through a WAF rule checking first-level tags.
Xssmaze.push("modern-bypass-level20", "/modern-bypass/level20/?query=a", "Double URL decoding / double escape bypass", "GET", ["query"],
  vuln: "reflected-html", delivery: ["query"], note: "the value is URL-decoded a second time after the WAF check, so double-encode the handler name as well as the angle brackets: %253Cimg%2520src%253Dx%2520%256Fnerror%253Dalert(1)%253E")
maze_get "/modern-bypass/level20/" do |env|
  query = env.params.query.fetch("query", "")

  # WAF rule: block raw script tags, angle brackets, or onload/onerror attributes in first-decoded query
  if query.match(/<|>|onload|onerror/i)
    halt env, status_code: 403, response: "WAF Blocked: Dangerous characters detected in query!"
  end

  # Application double-decodes explicitly to support nested/legacy API serialization
  double_decoded = URI.decode_www_form(query)

  "<!doctype html><html><head><meta charset='utf-8'><title>Search Dashboard</title></head><body>
  <h1>Double Decode Search</h1>
  <p>Double URL decoded output returned safely:</p>
  <div class='result-box'>#{double_decoded}</div>
  </body></html>"
end

# Level 21: Context-Breaking JSON Script Tag Injection (Auto-Escaping Failure)
# The application serializes a Crystal Hash to JSON and reflects it raw in a script block.
# An attacker closes the script block with </script> and opens a new one, breaking JS parser rules.
Xssmaze.push("modern-bypass-level21", "/modern-bypass/level21/?query=a", "Context-breaking JSON script tag injection", "GET", ["query"],
  vuln: "reflected-js", delivery: ["query"], note: "the value is JSON-serialised, so quotes are escaped, but </script> is not: close the script block and open a new one")
maze_get "/modern-bypass/level21/" do |env|
  query = env.params.query.fetch("query", "")

  # The application serializes user-submitted data to a JSON configuration object
  config_data = {
    "username" => query,
    "role"     => "guest",
    "status"   => "active",
  }

  "<!doctype html><html><head><meta charset='utf-8'><title>Workspace Configuration</title></head><body>
  <h1>System Workspace Settings</h1>
  <p>Check the console for initialized configurations.</p>

  <script>
    // Config data serialized raw into the script block:
    var globalConfig = #{config_data.to_json};
    console.log('Successfully loaded config:', globalConfig);
  </script>
  </body></html>"
end

# Level 22: Alpine.js Directive Injection (Attribute Context)
# Input is placed directly inside a div element's tag body as a custom attribute. Quotes are HTML-escaped to prevent attribute breakout.
# Evaluated via Alpine.js directives (like x-init) which do not require quotes to run code in HTML.
Xssmaze.push("modern-bypass-level22", "/modern-bypass/level22/?query=a", "Alpine.js directive attribute injection", "GET", ["query"],
  vuln: "reflected-attr", delivery: ["query"], note: "quotes and angle brackets are HTML-escaped, so the payload has to be an unquoted Alpine directive in attribute-name position, e.g. x-init=alert(1); needs the jsdelivr CDN to be reachable")
maze_get "/modern-bypass/level22/" do |env|
  query = env.params.query.fetch("query", "")

  # Escape double and single quotes to prevent breaking out of attribute parameters
  escaped = HTML.escape(query)

  "<!doctype html><html><head><meta charset='utf-8'>
  <title>Component Showcase</title>
  <script src='https://cdn.jsdelivr.net/npm/alpinejs@3.12.0/dist/cdn.min.js' defer></script>
  </head><body>
  <h1>Interactive Component Dashboard</h1>
  <p>The system renders user-defined attributes on this showcase component:</p>

  <!-- Injection context: inside the element tag directly. Quotes are escaped but Alpine evaluates injected directives -->
  <div id='interactive-component' #{escaped}>
    Toggle Component Options
  </div>
  </body></html>"
end

# Level 23: Meta CSP Pre-Execution Race (Reflection before <meta> tag)
# The application defines strict CSP via a <meta> tag in the head, but user reflection lands
# before the meta tag. The browser runs injected scripts before parsing the CSP policy.
Xssmaze.push("modern-bypass-level23", "/modern-bypass/level23/?query=a", "Meta CSP pre-execution race condition (reflection before meta tag)", "GET", ["query"],
  vuln: "reflected-html", delivery: ["query"], note: "the reflection lands in <head> before the CSP <meta>, which only covers what follows it, so a script injected here runs under script-src none")
maze_get "/modern-bypass/level23/" do |env|
  query = env.params.query.fetch("query", "")

  "<!doctype html><html><head><meta charset='utf-8'>
  <!-- Reflection lands before CSP registration -->
  #{query}
  <meta http-equiv='Content-Security-Policy' content=\"default-src 'self'; script-src 'none'; object-src 'none';\">
  <title>Secured System Portal</title>
  </head><body>
  <h1>System Security Portal</h1>
  <p>The page enforces a strict CSP policy that blocks all script execution. However, check if scripts reflected early are executed.</p>
  </body></html>"
end

# Level 24: AngularJS Client-Side Template Injection (CSTI) under Strict Tag Filters
# Angle brackets are entirely stripped. Evaluated inside AngularJS framework container.
Xssmaze.push("modern-bypass-level24", "/modern-bypass/level24/?query=a", "AngularJS Client-Side Template Injection (CSTI) bypassing HTML tags", "GET", ["query"],
  vuln: "csti", delivery: ["query"], note: "AngularJS 1.6.9 ng-app scope and angle brackets are stripped, so the payload is a {{ }} expression; needs the googleapis CDN to be reachable")
maze_get "/modern-bypass/level24/" do |env|
  query = env.params.query.fetch("query", "")

  # Strip angle brackets completely
  sanitized = query.gsub("<", "").gsub(">", "")

  "<!doctype html><html><head><meta charset='utf-8'>
  <title>Customer Feedback</title>
  <script src='https://ajax.googleapis.com/ajax/libs/angularjs/1.6.9/angular.min.js'></script>
  </head><body>
  <div ng-app=''>
    <h1>Feedback Portal</h1>
    <p>Search keyword: #{sanitized}</p>
  </div>
  </body></html>"
end

# Level 25: ES6 Template Literal Backtick Breakout with Placeholders
# Reflections landing inside template literals can be exploited using ES6 placeholders `${...}`
# or by escaping/using backticks if not filtered.
Xssmaze.push("modern-bypass-level25", "/modern-bypass/level25/?query=a", "ES6 JS Template Literal Placeholder Injection", "GET", ["query"],
  vuln: "reflected-js", delivery: ["query"], note: "both quote characters are backslash-escaped, but the value lands inside a backtick template literal; ${alert(1)} evaluates")
maze_get "/modern-bypass/level25/" do |env|
  query = env.params.query.fetch("query", "")

  # Escape double/single quotes to block traditional JS context breakout
  escaped = query.gsub("\"", "\\\"").gsub("'", "\\'")

  "<!doctype html><html><head><meta charset='utf-8'><title>Workspace Init</title></head><body>
  <h1>ES6 Workspace Loader</h1>
  <div id='log'>Awaiting loading logs...</div>

  <script>
    // Injected inside ES6 backtick template literal:
    var message = `User workspace initialized: #{escaped}`;
    document.getElementById('log').textContent = message;
  </script>
  </body></html>"
end

# Level 26: Nested Query Parameter Prototype Pollution XSS
# Simulates deep query string key parsing where __proto__ allows poisoning object prototypes.
Xssmaze.push("modern-bypass-level26", "/modern-bypass/level26/?query=a", "Query parameter recursive parsing prototype pollution to DOM XSS", "GET", ["query"],
  vuln: "prototype-pollution", sources: ["location.search"], sinks: ["script.src"], delivery: ["query"], note: "the parser splits keys on a pipe, not on brackets, so the bracket shape its own comment advertises does nothing; use ?__proto__|scriptUrl=data:text/javascript,alert(1)")
maze_get "/modern-bypass/level26/" do |_env|
  "<!doctype html><html><head><meta charset='utf-8'><title>Admin Config Console</title></head><body>
  <h1>Configuration Loader</h1>
  <div id='status'>Loading configuration modules...</div>

  <script>
    // A simple query parser that handles nested keys like: ?config[__proto__][scriptUrl]=...
    function parseNestedParams(queryString) {
      var params = {};
      var pairs = queryString.substring(1).split('&');

      for (var i = 0; i < pairs.length; i++) {
        var pair = pairs[i].split('=');
        if (!pair[0]) continue;

        var key = decodeURIComponent(pair[0]);
        var value = decodeURIComponent(pair[1] || '');

        // Match nested structure like key[subKey]
        var parts = key.split(/[|]/).filter(Boolean);
        var current = params;

        for (var j = 0; j < parts.length; j++) {
          var part = parts[j];
          if (j === parts.length - 1) {
            current[part] = value;
          } else {
            if (!current[part]) {
              current[part] = {};
            }
            current = current[part];
          }
        }
      }
      return params;
    }

    setTimeout(function() {
      var parsed = parseNestedParams(window.location.search);
      var config = {};

      // Sink: dynamic script injection if global prototype has been polluted
      var scriptUrl = config.scriptUrl;
      if (scriptUrl) {
        var s = document.createElement('script');
        s.src = scriptUrl;
        document.body.appendChild(s);
        document.getElementById('status').textContent = 'Dynamic module loaded from: ' + scriptUrl;
      } else {
        document.getElementById('status').textContent = 'Default workspace loaded.';
      }
    }, 500);
  </script>
  </body></html>"
end
