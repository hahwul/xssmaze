Xssmaze.push("csp-bypass-level1", "/csp/level1/?query=a", "CSP bypass with unsafe-inline",
  vuln: "reflected-html", delivery: ["query"], note: "script-src 'unsafe-inline', so an injected inline <script> executes")
maze_get "/csp/level1/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-inline'"

  "<html><head></head><body>
  <h1>CSP Level 1</h1>
  <div>User input: #{query}</div>
  </body></html>"
end

Xssmaze.push("csp-bypass-level2", "/csp/level2/?query=a", "CSP bypass with nonce",
  vuln: "reflected-js", delivery: ["query"], note: "the reflection is inside a nonce'd inline <script>, so breaking the single-quoted string runs under that nonce; the nonce is the fixed literal abc123, so an injected <script nonce='abc123'> passes too")
maze_get "/csp/level2/" do |env|
  query = env.params.query.fetch("query", "")
  nonce = "abc123"
  env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'nonce-#{nonce}'"

  "<html><head></head><body>
  <h1>CSP Level 2</h1>
  <script nonce='#{nonce}'>
    document.write('#{query}')
  </script>
  </body></html>"
end

Xssmaze.push("csp-bypass-level3", "/csp/level3/?query=a", "CSP bypass with eval and unsafe-eval",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "the value does land raw in a JS string, but script-src 'unsafe-eval' carries no 'unsafe-inline', nonce or host source, so the page's own inline <script> never runs and no injected script or event handler can run either; reporting no XSS here is the correct result")
maze_get "/csp/level3/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-eval'"

  "<html><head></head><body>
  <h1>CSP Level 3</h1>
  <script>
    eval('var userInput = \"#{query}\"; document.write(userInput);')
  </script>
  </body></html>"
end

Xssmaze.push("csp-bypass-level4", "/csp/level4/?query=a", "CSP bypass with strict policy (data: URI)",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "default-src 'self' blocks the data: iframe that would carry the payload and script-src 'self' blocks the inline listener that would render it, so neither half of the postMessage round-trip executes")
maze_get "/csp/level4/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'"

  "<html><head></head><body>
  <h1>CSP Level 4</h1>
  <iframe src=\"data:text/html,<script>parent.postMessage('#{query}','*')</script>\"></iframe>
  <script>
    window.addEventListener('message', function(e) {
      document.body.innerHTML += '<div>' + e.data + '</div>';
    });
  </script>
  </body></html>"
end

Xssmaze.push("csp-bypass-level5", "/csp/level5/?query=a", "CSP bypass with meta tag injection",
  vuln: "reflected-html", delivery: ["query"], note: "the meta-tag CSP allows 'unsafe-inline', so the raw reflection executes")
maze_get "/csp/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head>
  <meta http-equiv='Content-Security-Policy' content=\"default-src 'self'; script-src 'unsafe-inline'\">
  </head><body>
  <h1>CSP Level 5</h1>
  #{query}
  </body></html>"
end
