def load_mixed_method_xss
  # Level 1: GET param 'query' reflected raw — standard baseline
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("mixedmethod-level1", "/mixed-method/level1/?query=a", "GET param query reflected raw (also works via query string on POST)")
  maze_get "/mixed-method/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>#{query}</body></html>"
  end
  maze_post "/mixed-method/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>#{query}</body></html>"
  end

  # Level 2: Param name is 'input' (not 'query') reflected raw
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("mixedmethod-level2", "/mixed-method/level2/?input=a", "GET param 'input' reflected raw (non-standard param name)", "GET", ["input"])
  maze_get "/mixed-method/level2/" do |env|
    query = env.params.query["input"]

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Param name is 'search' reflected in <h2>Results for: SEARCH</h2>
  # Bypass: </h2><script>alert(1)</script>
  Xssmaze.push("mixedmethod-level3", "/mixed-method/level3/?search=a", "GET param 'search' reflected in h2 heading", "GET", ["search"])
  maze_get "/mixed-method/level3/" do |env|
    query = env.params.query["search"]

    "<html><body><h2>Results for: #{query}</h2></body></html>"
  end

  # Level 4: Param name is 'q' (short) reflected raw
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("mixedmethod-level4", "/mixed-method/level4/?q=a", "GET param 'q' reflected raw (short param name)", "GET", ["q"])
  maze_get "/mixed-method/level4/" do |env|
    query = env.params.query["q"]

    "<html><body>#{query}</body></html>"
  end

  # Level 5: Param name is 'callback' reflected raw — JSONP-style param discovery
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("mixedmethod-level5", "/mixed-method/level5/?callback=a", "GET param 'callback' reflected raw in HTML body", "GET", ["callback"])
  maze_get "/mixed-method/level5/" do |env|
    query = env.params.query["callback"]

    "<html><body>#{query}</body></html>"
  end

  # Level 6: Param name is 'redirect_url' reflected in <a href="QUERY">
  # Bypass: javascript:alert(1)
  Xssmaze.push("mixedmethod-level6", "/mixed-method/level6/?redirect_url=a", "GET param 'redirect_url' reflected in href (javascript: protocol)", "GET", ["redirect_url"])
  maze_get "/mixed-method/level6/" do |env|
    query = env.params.query["redirect_url"]

    "<html><body><a href=\"#{query}\">Click here to continue</a></body></html>"
  end
end
