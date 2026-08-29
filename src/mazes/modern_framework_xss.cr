# Level 1: React-style dangerouslySetInnerHTML simulation
Xssmaze.push("modern-level1", "/modern/level1/?query=a", "dangerouslySetInnerHTML simulation",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "the value is percent-encoded into the JS string and decoded client-side, so there is no string breakout; innerHTML does not run a bare <script>, so use <img src=x onerror=...>")
maze_get "/modern/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <div id='app'></div>
  <script>
  var content = decodeURIComponent('#{URI.encode_path(query)}');
  document.getElementById('app').innerHTML = content;
  </script>
  </body></html>"
end

# Level 2: Server-side markdown rendering (XSS via markdown link)
Xssmaze.push("modern-level2", "/modern/level2/?query=a", "markdown link rendering",
  vuln: "reflected-html", delivery: ["query"], note: "the whole value is reflected raw, so the markdown rewrite is not needed; [x](javascript:alert(1)) additionally builds a clickable href")
maze_get "/modern/level2/" do |env|
  query = env.params.query.fetch("query", "")
  # Simple markdown-to-html: [text](url) -> <a href="url">text</a>
  html = query.gsub(/\[([^\]]*)\]\(([^)]*)\)/) do |_match|
    text = $1
    url = $2
    "<a href=\"#{url}\">#{text}</a>"
  end

  "<html><body><div>#{html}</div></body></html>"
end

# Level 3: GraphQL-style error reflection
Xssmaze.push("modern-level3", "/modern/level3/?query=a", "GraphQL error message reflection",
  vuln: "reflected-html", delivery: ["query"], note: "the response is text/html and the JSON-looking envelope is just <pre> text, so the value is a plain HTML-body reflection")
maze_get "/modern/level3/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>GraphQL Error</h1>
  <pre>{\"errors\":[{\"message\":\"Unknown field '#{query}' on type 'Query'\"}]}</pre>
  </body></html>"
end

# Level 4: SSR hydration mismatch - server escapes but client doesn't
Xssmaze.push("modern-level4", "/modern/level4/?query=a", "SSR hydration with client innerHTML",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"], note: "the server-side copy is entity-encoded and is a decoy; the page re-reads the raw query parameter into innerHTML, so use <img src=x onerror=...>")
maze_get "/modern/level4/" do |env|
  query = env.params.query.fetch("query", "")
  server_safe = Filters.encode_angles(query)

  "<html><body>
  <div id='ssr'>#{server_safe}</div>
  <script>
  var raw = new URLSearchParams(location.search).get('query') || '';
  document.getElementById('ssr').innerHTML = raw;
  </script>
  </body></html>"
end

# Level 5: CORS response with reflected origin
Xssmaze.push("modern-level5", "/modern/level5/?query=a", "reflected in CORS headers + body",
  vuln: "reflected-html", delivery: ["query"], note: "the Access-Control-Allow-Origin echo is header-sanitised and not injectable; the bug is the raw body reflection of query")
maze_get "/modern/level5/" do |env|
  query = env.params.query.fetch("query", "a")
  origin = env.request.headers.fetch("Origin", "*")
  env.response.headers["Access-Control-Allow-Origin"] = Xssmaze.header_value(origin)

  "<html><body>#{query}</body></html>"
end

# Level 6: WebSocket URL injection
Xssmaze.push("modern-level6", "/modern/level6/?wsurl=ws://localhost", "WebSocket URL injection", "GET", ["wsurl"],
  vuln: "reflected-js", delivery: ["query"], note: "the parameter is wsurl, not query; it lands raw in a single-quoted JS string, so close the string and run code")
maze_get "/modern/level6/" do |env|
  wsurl = env.params.query.fetch("wsurl", "ws://localhost")

  "<html><body>
  <script>
  try { var ws = new WebSocket('#{wsurl}'); } catch(e) {}
  </script>
  <div>Connecting to WebSocket...</div>
  </body></html>"
end
