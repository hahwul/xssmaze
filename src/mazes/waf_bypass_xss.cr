# Level 1: Strips <script> (case-insensitive, non-recursive) but allows other tags
Xssmaze.push("waf-bypass-level1", "/waf-bypass/level1/?query=a", "case-insensitive script tag strip",
  vuln: "reflected-html", delivery: ["query"], note: "script removed once and case-insensitively; use a nested tag or a non-script vector")
maze_get "/waf-bypass/level1/" do |env|
  query = Filters.strip_keyword_ci(env.params.query["query"], "script")

  "<html><body>#{query}</body></html>"
end

# Level 2: Strips alert/confirm/prompt (case-insensitive)
Xssmaze.push("waf-bypass-level2", "/waf-bypass/level2/?query=a", "alert/confirm/prompt function strip",
  vuln: "reflected-html", delivery: ["query"], note: "alert/confirm/prompt names are stripped; use another sink such as Function or a string-built name")
maze_get "/waf-bypass/level2/" do |env|
  query = Filters.strip_keyword_ci(env.params.query["query"], "alert")
  query = Filters.strip_keyword_ci(query, "confirm")
  query = Filters.strip_keyword_ci(query, "prompt")

  "<html><body>#{query}</body></html>"
end

# Level 3: Strips on* event handler + < > encoded + in attribute
Xssmaze.push("waf-bypass-level3", "/waf-bypass/level3/?query=a", "event strip + angle encode in double-quote attr",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "reflected into a double-quoted input value, but angle brackets are entity-encoded (no new tags) and every on*= handler is stripped, so the attribute breakout reaches no JS sink")
maze_get "/waf-bypass/level3/" do |env|
  query = Filters.encode_angles(env.params.query["query"])
  query = Filters.strip_event_handlers(query)

  "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
end

# Level 4: Replaces ' and " with HTML entities, reflection in JS context
Xssmaze.push("waf-bypass-level4", "/waf-bypass/level4/?query=a", "quote entity escape in JS string",
  vuln: "reflected-js", delivery: ["query"], note: "quotes are entity-escaped so the JS string cannot be broken, but angle brackets pass, so close the </script> to inject HTML")
maze_get "/waf-bypass/level4/" do |env|
  query = env.params.query["query"]
  # Only escape quotes, allow angle brackets (for </script> breakout)
  query = query.gsub("'", "&#39;").gsub("\"", "&quot;")

  "<script>var x = '#{query}';</script>"
end

# Level 5: Strip <, but not >. Single angle is sufficient for some browsers.
Xssmaze.push("waf-bypass-level5", "/waf-bypass/level5/?query=a", "only < stripped (> allowed)",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "every < is stripped, so no tag can be opened in the body context; the reflection is inert")
maze_get "/waf-bypass/level5/" do |env|
  query = env.params.query["query"].gsub("<", "")

  "<html><body>#{query}</body></html>"
end

# Level 6: Double write - input reflected in both src attribute and body
Xssmaze.push("waf-bypass-level6", "/waf-bypass/level6/?query=a", "dual reflection: src attribute + body",
  vuln: "reflected-html", delivery: ["query"], note: "reflected into both an img src attribute and the body; the body is a direct HTML injection")
maze_get "/waf-bypass/level6/" do |env|
  query = env.params.query["query"]

  "<html><body><img src=\"#{query}\"><div>Search: #{query}</div></body></html>"
end

# Level 7: Lowercase conversion + strip "script" keyword (case bypass needed)
Xssmaze.push("waf-bypass-level7", "/waf-bypass/level7/?query=a", "lowercase + script keyword strip",
  vuln: "reflected-html", delivery: ["query"], note: "input is lowercased then script removed; use a lowercase non-script vector")
maze_get "/waf-bypass/level7/" do |env|
  query = env.params.query["query"].downcase
  query = query.gsub("script", "")

  "<html><body>#{query}</body></html>"
end

# Level 8: Strip = sign (prevents attribute-based events)
# Exploitable via: <script>alert(1)</script> (no = needed)
Xssmaze.push("waf-bypass-level8", "/waf-bypass/level8/?query=a", "equals sign stripped",
  vuln: "reflected-html", delivery: ["query"], note: "= is stripped; use a tag that needs no attribute value (e.g. <script>)")
maze_get "/waf-bypass/level8/" do |env|
  query = env.params.query["query"].gsub("=", "")

  "<html><body>#{query}</body></html>"
end
