def load_waf_bypass_xss
  # Level 1: Strips <script> (case-insensitive, non-recursive) but allows other tags
  Xssmaze.push("waf-bypass-level1", "/waf-bypass/level1/?query=a", "case-insensitive script tag strip")
  maze_get "/waf-bypass/level1/" do |env|
    query = Filters.strip_keyword_ci(env.params.query["query"], "script")

    "<html><body>#{query}</body></html>"
  end

  # Level 2: Strips alert/confirm/prompt (case-insensitive)
  Xssmaze.push("waf-bypass-level2", "/waf-bypass/level2/?query=a", "alert/confirm/prompt function strip")
  maze_get "/waf-bypass/level2/" do |env|
    query = Filters.strip_keyword_ci(env.params.query["query"], "alert")
    query = Filters.strip_keyword_ci(query, "confirm")
    query = Filters.strip_keyword_ci(query, "prompt")

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Strips on* event handler + < > encoded + in attribute
  Xssmaze.push("waf-bypass-level3", "/waf-bypass/level3/?query=a", "event strip + angle encode in double-quote attr")
  maze_get "/waf-bypass/level3/" do |env|
    query = Filters.encode_angles(env.params.query["query"])
    query = Filters.strip_event_handlers(query)

    "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
  end

  # Level 4: Replaces ' and " with HTML entities, reflection in JS context
  Xssmaze.push("waf-bypass-level4", "/waf-bypass/level4/?query=a", "quote entity escape in JS string")
  maze_get "/waf-bypass/level4/" do |env|
    query = env.params.query["query"]
    # Only escape quotes, allow angle brackets (for </script> breakout)
    query = query.gsub("'", "&#39;").gsub("\"", "&quot;")

    "<script>var x = '#{query}';</script>"
  end

  # Level 5: Strip <, but not >. Single angle is sufficient for some browsers.
  Xssmaze.push("waf-bypass-level5", "/waf-bypass/level5/?query=a", "only < stripped (> allowed)")
  maze_get "/waf-bypass/level5/" do |env|
    query = env.params.query["query"].gsub("<", "")

    "<html><body>#{query}</body></html>"
  end

  # Level 6: Double write - input reflected in both src attribute and body
  Xssmaze.push("waf-bypass-level6", "/waf-bypass/level6/?query=a", "dual reflection: src attribute + body")
  maze_get "/waf-bypass/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><img src=\"#{query}\"><div>Search: #{query}</div></body></html>"
  end

  # Level 7: Lowercase conversion + strip "script" keyword (case bypass needed)
  Xssmaze.push("waf-bypass-level7", "/waf-bypass/level7/?query=a", "lowercase + script keyword strip")
  maze_get "/waf-bypass/level7/" do |env|
    query = env.params.query["query"].downcase
    query = query.gsub("script", "")

    "<html><body>#{query}</body></html>"
  end

  # Level 8: Strip = sign (prevents attribute-based events)
  # Exploitable via: <script>alert(1)</script> (no = needed)
  Xssmaze.push("waf-bypass-level8", "/waf-bypass/level8/?query=a", "equals sign stripped")
  maze_get "/waf-bypass/level8/" do |env|
    query = env.params.query["query"].gsub("=", "")

    "<html><body>#{query}</body></html>"
  end
end
