def load_polyglot_context_xss
  # Level 1: Query reflected both in HTML body AND in an attribute — either context is exploitable
  Xssmaze.push("polyctx-level1", "/polyctx/level1/?query=a", "dual reflection: body + attribute value")
  maze_get "/polyctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Polyglot Context Level 1</h1>
    <input type=\"text\" value=\"#{query}\">
    <div>#{query}</div>
    </body></html>"
  end

  # Level 2: Query reflected both inside <script>var x="QUERY"</script> AND in HTML body
  # </script> breakout works for both
  Xssmaze.push("polyctx-level2", "/polyctx/level2/?query=a", "dual reflection: script string + body")
  maze_get "/polyctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Polyglot Context Level 2</h1>
    <script>var x=\"#{query}\"</script>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 3: Query reflected in 3 places: HTML comment, attribute, and body — all exploitable
  Xssmaze.push("polyctx-level3", "/polyctx/level3/?query=a", "triple reflection: comment + attribute + body")
  maze_get "/polyctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Polyglot Context Level 3</h1>
    <!-- #{query} -->
    <div title=\"#{query}\">#{query}</div>
    </body></html>"
  end

  # Level 4: Query reflected in HTML body with <script> stripped (single pass) — use <img> tag instead
  Xssmaze.push("polyctx-level4", "/polyctx/level4/?query=a", "single-pass script tag strip, body reflection")
  maze_get "/polyctx/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/<script[^>]*>|<\/script>/i, "")

    "<html><body>
    <h1>Polyglot Context Level 4</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 5: Query reflected in both single-quoted JS and double-quoted HTML attribute
  # </script> breakout covers both
  Xssmaze.push("polyctx-level5", "/polyctx/level5/?query=a", "dual reflection: JS single-quoted + HTML double-quoted attr")
  maze_get "/polyctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Polyglot Context Level 5</h1>
    <script>var msg='#{query}';</script>
    <input type=\"text\" value=\"#{query}\">
    </body></html>"
  end

  # Level 6: Query reflected in <style>QUERY</style> AND <div>QUERY</div>
  # </style> breakout for first, direct injection for second
  Xssmaze.push("polyctx-level6", "/polyctx/level6/?query=a", "dual reflection: style tag + body div")
  maze_get "/polyctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <style>body { color: #{query}; }</style>
    </head><body>
    <h1>Polyglot Context Level 6</h1>
    <div>#{query}</div>
    </body></html>"
  end
end
