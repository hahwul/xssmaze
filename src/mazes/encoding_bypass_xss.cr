require "base64"

# Level 1: Strips <script> recursively but allows other tags
Xssmaze.push("encoding-bypass-level1", "/encoding-bypass/level1/?query=a", "recursive script strip (other tags allowed)",
  vuln: "reflected-html", delivery: ["query"], note: "script is stripped recursively so nesting does not help; every other tag and event handler is untouched")
maze_get "/encoding-bypass/level1/" do |env|
  query = Filters.strip_keyword_recursive(env.params.query.fetch("query", ""), "script")

  "<html><body>#{query}</body></html>"
end

# Level 2: Strips < > but only first occurrence each
Xssmaze.push("encoding-bypass-level2", "/encoding-bypass/level2/?query=a", "single < > strip (only first occurrence)",
  vuln: "reflected-html", delivery: ["query"], note: "only the first < and the first > are removed; double them up")
maze_get "/encoding-bypass/level2/" do |env|
  query = env.params.query.fetch("query", "")
  query = query.sub("<", "")
  query = query.sub(">", "")

  "<html><body>#{query}</body></html>"
end

# Level 3: Replaces 'alert' with empty string (non-recursive)
Xssmaze.push("encoding-bypass-level3", "/encoding-bypass/level3/?query=a", "alert keyword strip (non-recursive)",
  vuln: "reflected-html", delivery: ["query"], note: "only the literal alert keyword is stripped, in a single pass; alalertert survives, and any other sink is untouched")
maze_get "/encoding-bypass/level3/" do |env|
  query = Filters.strip_keyword_ci(env.params.query.fetch("query", ""), "alert")

  "<html><body>#{query}</body></html>"
end

# Level 4: Strips on* event handlers but not from within quoted strings
Xssmaze.push("encoding-bypass-level4", "/encoding-bypass/level4/?query=a", "event handler strip + tag allowed",
  vuln: "reflected-html", delivery: ["query"], note: "on*= handlers are stripped, but tags are not")
maze_get "/encoding-bypass/level4/" do |env|
  query = Filters.strip_event_handlers(env.params.query.fetch("query", ""))

  "<html><body>#{query}</body></html>"
end

# Level 5: Lowercase + strip javascript: but allows data: protocol
Xssmaze.push("encoding-bypass-level5", "/encoding-bypass/level5/?query=a", "javascript: strip but data: allowed in href",
  vuln: "reflected-attr", delivery: ["query"], note: "javascript: is stripped and data: is not, but the double-quoted href can simply be broken out of")
maze_get "/encoding-bypass/level5/" do |env|
  query = Filters.strip_js_protocol(env.params.query.fetch("query", ""))

  "<html><body><a href=\"#{query}\">Click</a></body></html>"
end

# Level 6: URL decode then strip < > (double URL encode bypass)
Xssmaze.push("encoding-bypass-level6", "/encoding-bypass/level6/?query=a", "URL decode + angle strip (double encode bypass)",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "the description promises a double-encoding bypass, but the angle-bracket strip runs after the decode, so no < or > can reach the body context")
maze_get "/encoding-bypass/level6/" do |env|
  query = URI.decode(env.params.query.fetch("query", ""))
  query = Filters.strip_angles(query)

  "<html><body>#{query}</body></html>"
rescue
  "Decode Error"
end

# Level 7: Whitelist img/div/span tags, strip everything else
Xssmaze.push("encoding-bypass-level7", "/encoding-bypass/level7/?query=a", "tag whitelist (img/div/span only)",
  vuln: "reflected-html", delivery: ["query"], note: "only img/div/span survive the whitelist, and img carries onerror")
maze_get "/encoding-bypass/level7/" do |env|
  query = Filters.whitelist_tags(env.params.query.fetch("query", ""), ["img", "div", "span"])

  "<html><body>#{query}</body></html>"
end

# Level 8: Length limit 60 chars + no quote escape
Xssmaze.push("encoding-bypass-level8", "/encoding-bypass/level8/?query=a", "60 char length limit in attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "the value is truncated to 60 characters, so the whole breakout has to fit")
maze_get "/encoding-bypass/level8/" do |env|
  query = env.params.query.fetch("query", "")[0, 60]

  "<html><body><div class=\"#{query}\">Hello</div></body></html>"
end
