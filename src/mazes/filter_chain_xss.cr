def load_filter_chain_xss
  # Level 1: Strip <script>, <img>, <svg> tags but allow <details>, <select>, <input>
  Xssmaze.push("filterchain-level1", "/filterchain/level1/?query=a", "common tag blacklist (script/img/svg stripped)")
  maze_get "/filterchain/level1/" do |env|
    query = Filters.strip_tags(env.params.query["query"], ["script", "img", "svg", "iframe", "object", "embed", "link", "style"])

    "<html><body>#{query}</body></html>"
  end

  # Level 2: Strip all event handlers + strip <script> tags
  Xssmaze.push("filterchain-level2", "/filterchain/level2/?query=a", "event handlers + script tags stripped")
  maze_get "/filterchain/level2/" do |env|
    query = Filters.strip_event_handlers(env.params.query["query"])
    query = Filters.strip_tags(query, ["script"])

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Lowercase conversion + strip "javascript:" + strip "data:" + attribute context
  Xssmaze.push("filterchain-level3", "/filterchain/level3/?query=a", "lowercase + protocol strip in href")
  maze_get "/filterchain/level3/" do |env|
    query = env.params.query["query"].downcase
    query = Filters.strip_js_protocol(query)
    query = query.gsub(/data\s*:/i, "")

    "<html><body><a href=\"#{query}\">Link</a></body></html>"
  end

  # Level 4: Encode < > to entities + strip " but allow ' (single quote attribute)
  Xssmaze.push("filterchain-level4", "/filterchain/level4/?query=a", "angle encode + double quote strip in single-quote attr")
  maze_get "/filterchain/level4/" do |env|
    query = Filters.encode_angles(env.params.query["query"])
    query = query.gsub("\"", "")

    "<html><body><div class='#{query}'>Hello</div></body></html>"
  end

  # Level 5: Strip parentheses + backtick + angle brackets, reflection in body
  # Requires payloads like: <img src=x onerror=alert`1`> won't work, need alternative
  Xssmaze.push("filterchain-level5", "/filterchain/level5/?query=a", "parens + backtick + angles all stripped")
  maze_get "/filterchain/level5/" do |env|
    query = env.params.query["query"]
    query = Filters.strip_angles(query)
    query = Filters.strip_parens(query)
    query = query.gsub("`", "")

    "<div class=\"#{query}\">Hello</div>"
  end

  # Level 6: URL in attribute; strips javascript: / data: / vbscript:, allows http/https
  # Requires: attribute breakout with ">, or clever protocol bypass
  Xssmaze.push("filterchain-level6", "/filterchain/level6/?query=a", "protocol whitelist bypass in src")
  maze_get "/filterchain/level6/" do |env|
    query = env.params.query["query"]
    query = Filters.strip_js_protocol(query)
    query = query.gsub(/data\s*:/i, "")
    query = query.gsub(/vbscript\s*:/i, "")

    "<html><body><iframe src=\"#{query}\"></iframe></body></html>"
  end

  # Level 7: strip < > and all quotes, reflection in unquoted attribute
  Xssmaze.push("filterchain-level7", "/filterchain/level7/?query=a", "angles+quotes stripped, unquoted attribute")
  maze_get "/filterchain/level7/" do |env|
    query = Filters.strip_angles(env.params.query["query"])
    query = Filters.escape_quotes(query)

    "<html><body><input type=text value=#{query} name=search></body></html>"
  end

  # Level 8: Reflection in JS, strip </script> and backslash, single-quoted context
  Xssmaze.push("filterchain-level8", "/filterchain/level8/?query=a", "JS context: close-script + backslash stripped")
  maze_get "/filterchain/level8/" do |env|
    query = env.params.query["query"]
    query = query.gsub("</script>", "").gsub("\\", "")

    "<script>var q = '#{query}';</script>"
  end
end
