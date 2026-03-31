def load_double_reflection_xss
  # Level 1: Query reflected twice in HTML body
  Xssmaze.push("doublereflect-level1", "/doublereflect/level1/?query=a", "query reflected twice in body")
  maze_get "/doublereflect/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Double Reflection Level 1</h1>
    <p>Your search: #{query}</p>
    <p>Results for: #{query}</p>
    </body></html>"
  end

  # Level 2: Query reflected raw in body AND in attribute with " encoded
  Xssmaze.push("doublereflect-level2", "/doublereflect/level2/?query=a", "body raw + attribute with quotes encoded")
  maze_get "/doublereflect/level2/" do |env|
    query = env.params.query["query"]
    attr_escaped = query.gsub("\"", "&quot;")

    "<html><body>
    <h1>Double Reflection Level 2</h1>
    <input type=\"text\" value=\"#{attr_escaped}\">
    <div>#{query}</div>
    </body></html>"
  end

  # Level 3: First reflection has <> encoded, second reflection is raw — second is exploitable
  Xssmaze.push("doublereflect-level3", "/doublereflect/level3/?query=a", "first reflection encoded, second raw")
  maze_get "/doublereflect/level3/" do |env|
    query = env.params.query["query"]
    encoded = Filters.encode_angles(query)

    "<html><body>
    <h1>Double Reflection Level 3</h1>
    <div class=\"safe\">#{encoded}</div>
    <div class=\"unsafe\">#{query}</div>
    </body></html>"
  end

  # Level 4: Query reflected in <title> AND <body> — both exploitable
  Xssmaze.push("doublereflect-level4", "/doublereflect/level4/?query=a", "reflection in title + body")
  maze_get "/doublereflect/level4/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <title>#{query}</title>
    </head><body>
    <h1>Double Reflection Level 4</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 5: Query reflected 5 times: 4 with HTML encoding, 1 raw at the end
  Xssmaze.push("doublereflect-level5", "/doublereflect/level5/?query=a", "4 encoded reflections + 1 raw at end")
  maze_get "/doublereflect/level5/" do |env|
    query = env.params.query["query"]
    encoded = Filters.encode_angles(query)

    "<html><body>
    <h1>Double Reflection Level 5</h1>
    <p>1: #{encoded}</p>
    <p>2: #{encoded}</p>
    <p>3: #{encoded}</p>
    <p>4: #{encoded}</p>
    <p>5: #{query}</p>
    </body></html>"
  end

  # Level 6: First reflection in script string (with " escaped), second in div raw
  Xssmaze.push("doublereflect-level6", "/doublereflect/level6/?query=a", "script string (quotes escaped) + div raw")
  maze_get "/doublereflect/level6/" do |env|
    query = env.params.query["query"]
    js_escaped = query.gsub("\"", "\\\"")

    "<html><body>
    <h1>Double Reflection Level 6</h1>
    <script>var x=\"#{js_escaped}\"</script>
    <div>#{query}</div>
    </body></html>"
  end
end
