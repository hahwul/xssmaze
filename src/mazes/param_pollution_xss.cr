def load_param_pollution_xss
  # Level 1: First param value used for display, second for filter check
  # HPP: duplicate param names cause different server behavior
  Xssmaze.push("hpp-level1", "/hpp/level1/?query=safe&query=a", "HTTP parameter pollution (first wins display)")
  maze_get "/hpp/level1/" do |env|
    values = env.params.query.fetch_all("query")
    # Server uses first value for display but checks last for filtering
    display = values.first? || "a"
    check = values.last? || "a"

    if check.includes?("<") || check.includes?(">")
      "<html><body>Blocked</body></html>"
    else
      "<html><body>#{display}</body></html>"
    end
  end

  # Level 2: Param splitting - query and q both reflected, but only query is filtered
  Xssmaze.push("hpp-level2", "/hpp/level2/?query=a&q=b", "param split: query filtered, q unfiltered")
  maze_get "/hpp/level2/" do |env|
    query = Filters.strip_angles(env.params.query.fetch("query", "a"))
    q = env.params.query.fetch("q", "b")

    "<html><body><div>#{query}</div><div>#{q}</div></body></html>"
  end

  # Level 3: Array parameter injection
  Xssmaze.push("hpp-level3", "/hpp/level3/?items[]=a&items[]=b", "array parameter injection")
  maze_get "/hpp/level3/" do |env|
    items = env.params.query.fetch_all("items[]")

    "<html><body><ul>#{items.map { |i| "<li>#{i}</li>" }.join}</ul></body></html>"
  end

  # Level 4: Param with dot notation (config.theme)
  Xssmaze.push("hpp-level4", "/hpp/level4/?config.theme=blue", "dot-notation parameter reflection")
  maze_get "/hpp/level4/" do |env|
    theme = env.params.query.fetch("config.theme", "default")

    "<html><body style=\"background: #{theme}\"><h1>Theme Page</h1></body></html>"
  end
end
