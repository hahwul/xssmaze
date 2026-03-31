def load_mutation_filter_xss
  # Level 1: Replace < with %3C (URL encode) before reflecting in body
  # Double URL decode might get it back
  Xssmaze.push("mutfilter-level1", "/mutfilter/level1/?query=a", "< replaced with %3C in body")
  maze_get "/mutfilter/level1/" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "%3C").gsub(">", "%3E")

    "<html><body>#{query}</body></html>"
  end

  # Level 2: Strip HTML comments but allow everything else
  Xssmaze.push("mutfilter-level2", "/mutfilter/level2/?query=a", "HTML comment strip only")
  maze_get "/mutfilter/level2/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/<!--.*?-->/m, "")

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Replace 'on' prefix with 'off' (breaks event handlers)
  Xssmaze.push("mutfilter-level3", "/mutfilter/level3/?query=a", "on* prefix replaced with off*")
  maze_get "/mutfilter/level3/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/\bon(\w)/i) { "off#{$1}" }

    "<html><body>#{query}</body></html>"
  end

  # Level 4: Strip src/href/action attributes but allow tags
  Xssmaze.push("mutfilter-level4", "/mutfilter/level4/?query=a", "dangerous attribute strip (src/href/action)")
  maze_get "/mutfilter/level4/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/\b(src|href|action|formaction)\s*=/i, "data-removed=")

    "<html><body>#{query}</body></html>"
  end

  # Level 5: Reverse string then unreverse (can be bypassed with palindrome payloads)
  Xssmaze.push("mutfilter-level5", "/mutfilter/level5/?query=a", "no filter (basic reflection)")
  maze_get "/mutfilter/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><p>#{query}</p></body></html>"
  end

  # Level 6: Remove all whitespace characters
  Xssmaze.push("mutfilter-level6", "/mutfilter/level6/?query=a", "all whitespace removed in body reflection")
  maze_get "/mutfilter/level6/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/\s/, "")

    "<html><body>#{query}</body></html>"
  end
end
