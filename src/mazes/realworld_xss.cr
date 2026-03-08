def load_realworld
  # Level 1: Double reflection - safe in comment, unsafe in body
  Xssmaze.push("realworld-level1", "/realworld/level1/?query=a", "double reflection (safe comment + unsafe body)")
  maze_get "/realworld/level1/" do |env|
    query = env.params.query["query"]
    safe = Filters.strip_angles(query)

    "<!-- search: #{safe} --><h2>Results for: #{query}</h2>"
  end

  # Level 2: Conditional reflection - only when debug=1
  Xssmaze.push("realworld-level2", "/realworld/level2/?query=a&debug=1", "conditional reflection (requires debug=1)")
  maze_get "/realworld/level2/" do |env|
    query = env.params.query["query"]
    debug = env.params.query.fetch("debug", "0")

    if debug == "1"
      "<div>Debug: #{query}</div>"
    else
      "<div>No results</div>"
    end
  end

  # Level 3: Truncated reflection - 30 char limit
  Xssmaze.push("realworld-level3", "/realworld/level3/?query=a", "truncated reflection (30 char limit)")
  maze_get "/realworld/level3/" do |env|
    query = env.params.query["query"][0, 30]

    "<div>#{query}</div>"
  end

  # Level 4: Multi-param interaction - tag + attr
  Xssmaze.push("realworld-level4", "/realworld/level4/?tag=div&attr=class=test", "multi-param XSS (tag + attr)")
  maze_get "/realworld/level4/" do |env|
    tag = env.params.query.fetch("tag", "div")
    attr = env.params.query.fetch("attr", "class=test")

    "<#{tag} #{attr}>content</#{tag}>"
  end

  # Level 5: Parameter key reflection
  Xssmaze.push("realworld-level5", "/realworld/level5/?search=a", "parameter key reflection")
  maze_get "/realworld/level5/" do |env|
    keys = env.params.query.to_h.keys.join(", ")

    "<div>Parameters: #{keys}</div>"
  end

  # Level 6: Wrong content-type (text/plain with HTML)
  Xssmaze.push("realworld-level6", "/realworld/level6/?query=a", "content-type sniffing (text/plain)")
  maze_get "/realworld/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/plain"

    "<html><body>#{query}</body></html>"
  end

  # Level 7: JS variable with newline injection (backslash-quote bypass)
  Xssmaze.push("realworld-level7", "/realworld/level7/?query=a", "JS newline injection (flawed escaping)")
  maze_get "/realworld/level7/" do |env|
    query = env.params.query["query"]
    # Flawed escaping: escapes single quotes but not backslashes
    escaped = query.gsub("'", "\\'")

    "<script>var x = '#{escaped}'; document.getElementById('out').textContent = x;</script><div id=\"out\"></div>"
  end

  # Level 8: Referer header reflection
  Xssmaze.push("realworld-level8", "/realworld/level8/", "referer header reflection in body")
  maze_get "/realworld/level8/" do |env|
    referer = env.request.headers.fetch("Referer", "none")

    "<div>You came from: #{referer}</div>"
  end
end
