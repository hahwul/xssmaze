def load_real_world_pattern_xss
  # Level 1: Search page with query in <input value="QUERY"> and in <p>Results for: QUERY</p>
  # Both reflection points are exploitable (attribute breakout + body injection)
  Xssmaze.push("rwpattern-level1", "/rwpattern/level1/?query=a", "search page: input value + results paragraph")
  maze_get "/rwpattern/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Search</h1>
    <form><input type=\"text\" value=\"#{query}\" name=\"query\"></form>
    <p>Results for: #{query}</p>
    </body></html>"
  end

  # Level 2: Profile page with query in <span class="username">QUERY</span>
  Xssmaze.push("rwpattern-level2", "/rwpattern/level2/?query=a", "profile page: username span injection")
  maze_get "/rwpattern/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div class=\"profile\">
      <h2>User Profile</h2>
      <span class=\"username\">#{query}</span>
    </div>
    </body></html>"
  end

  # Level 3: 404 page with query in <h1>404 - QUERY not found</h1>
  Xssmaze.push("rwpattern-level3", "/rwpattern/level3/?query=a", "404 page: path reflected in heading")
  maze_get "/rwpattern/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>404 - #{query} not found</h1>
    <p>The page you requested does not exist.</p>
    </body></html>"
  end

  # Level 4: Blog comment with query in <div class="comment"><p>QUERY</p></div>
  Xssmaze.push("rwpattern-level4", "/rwpattern/level4/?query=a", "blog comment: paragraph injection")
  maze_get "/rwpattern/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h2>Comments</h2>
    <div class=\"comment\"><p>#{query}</p></div>
    </body></html>"
  end

  # Level 5: Admin panel with query in <td>QUERY</td> and <title>Admin - QUERY</title>
  # Both reflection points are exploitable
  Xssmaze.push("rwpattern-level5", "/rwpattern/level5/?query=a", "admin panel: table cell + title injection")
  maze_get "/rwpattern/level5/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <title>Admin - #{query}</title>
    </head><body>
    <h1>Admin Panel</h1>
    <table><tr><td>#{query}</td></tr></table>
    </body></html>"
  end

  # Level 6: API documentation page with query in <code> and <pre> blocks
  # Break out of code/pre tags with standard injection
  Xssmaze.push("rwpattern-level6", "/rwpattern/level6/?query=a", "API docs: code + pre block injection")
  maze_get "/rwpattern/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>API Documentation</h1>
    <h3>Endpoint</h3>
    <code>GET /api/#{query}</code>
    <h3>Response</h3>
    <pre>{\"endpoint\": \"#{query}\"}</pre>
    </body></html>"
  end
end
