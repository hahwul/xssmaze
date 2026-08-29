Xssmaze.push("polyglot-level1", "/polyglot/level1/?query=a", "HTML comment breakout",
  vuln: "reflected-html", delivery: ["query"], note: "lands inside an HTML comment; close it with --> first")
maze_get "/polyglot/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Polyglot XSS Level 1</h1>
  <!-- #{query} -->
  <p>Comment breakout challenge.</p>
  </body></html>"
end

Xssmaze.push("polyglot-level2", "/polyglot/level2/?query=a", "meta refresh with URL sink",
  vuln: "reflected-attr", delivery: ["query"], note: "the meta-refresh target is not a usable sink in modern browsers, which block javascript: and data: navigations; the working route is a \" breakout out of the content attribute")
maze_get "/polyglot/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head>
  <meta http-equiv=\"refresh\" content=\"0;url=#{query}\">
  </head><body>
  <h1>Polyglot XSS Level 2</h1>
  <p>Meta refresh challenge.</p>
  </body></html>"
end

Xssmaze.push("polyglot-level3", "/polyglot/level3/?query=a", "triple URL decode",
  vuln: "reflected-html", delivery: ["query"], note: "the handler URL-decodes the already-decoded parameter three more times and rejects < after the second, so the payload needs four layers of encoding — %2525253C arrives as <")
maze_get "/polyglot/level3/" do |env|
  data = URI.decode(env.params.query.fetch("query", ""))
  data = URI.decode(data)
  if data.includes?("<")
    "Detect Special Character"
  else
    URI.decode(data)
  end
rescue
  "Decode Error"
end
