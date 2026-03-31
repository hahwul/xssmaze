require "base64"

def load_encoding_bypass_xss
  # Level 1: Strips <script> recursively but allows other tags
  Xssmaze.push("encoding-bypass-level1", "/encoding-bypass/level1/?query=a", "recursive script strip (other tags allowed)")
  maze_get "/encoding-bypass/level1/" do |env|
    query = Filters.strip_keyword_recursive(env.params.query["query"], "script")

    "<html><body>#{query}</body></html>"
  end

  # Level 2: Strips < > but only first occurrence each
  Xssmaze.push("encoding-bypass-level2", "/encoding-bypass/level2/?query=a", "single < > strip (only first occurrence)")
  maze_get "/encoding-bypass/level2/" do |env|
    query = env.params.query["query"]
    query = query.sub("<", "")
    query = query.sub(">", "")

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Replaces 'alert' with empty string (non-recursive)
  Xssmaze.push("encoding-bypass-level3", "/encoding-bypass/level3/?query=a", "alert keyword strip (non-recursive)")
  maze_get "/encoding-bypass/level3/" do |env|
    query = Filters.strip_keyword_ci(env.params.query["query"], "alert")

    "<html><body>#{query}</body></html>"
  end

  # Level 4: Strips on* event handlers but not from within quoted strings
  Xssmaze.push("encoding-bypass-level4", "/encoding-bypass/level4/?query=a", "event handler strip + tag allowed")
  maze_get "/encoding-bypass/level4/" do |env|
    query = Filters.strip_event_handlers(env.params.query["query"])

    "<html><body>#{query}</body></html>"
  end

  # Level 5: Lowercase + strip javascript: but allows data: protocol
  Xssmaze.push("encoding-bypass-level5", "/encoding-bypass/level5/?query=a", "javascript: strip but data: allowed in href")
  maze_get "/encoding-bypass/level5/" do |env|
    query = Filters.strip_js_protocol(env.params.query["query"])

    "<html><body><a href=\"#{query}\">Click</a></body></html>"
  end

  # Level 6: URL decode then strip < > (double URL encode bypass)
  Xssmaze.push("encoding-bypass-level6", "/encoding-bypass/level6/?query=a", "URL decode + angle strip (double encode bypass)")
  maze_get "/encoding-bypass/level6/" do |env|
    begin
      query = URI.decode(env.params.query["query"])
      query = Filters.strip_angles(query)

      "<html><body>#{query}</body></html>"
    rescue
      "Decode Error"
    end
  end

  # Level 7: Whitelist img/div/span tags, strip everything else
  Xssmaze.push("encoding-bypass-level7", "/encoding-bypass/level7/?query=a", "tag whitelist (img/div/span only)")
  maze_get "/encoding-bypass/level7/" do |env|
    query = Filters.whitelist_tags(env.params.query["query"], ["img", "div", "span"])

    "<html><body>#{query}</body></html>"
  end

  # Level 8: Length limit 60 chars + no quote escape
  Xssmaze.push("encoding-bypass-level8", "/encoding-bypass/level8/?query=a", "60 char length limit in attribute")
  maze_get "/encoding-bypass/level8/" do |env|
    query = env.params.query["query"][0, 60]

    "<html><body><div class=\"#{query}\">Hello</div></body></html>"
  end
end
