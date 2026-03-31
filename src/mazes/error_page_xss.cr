def load_error_page_xss
  # Level 1: 404-like error page with raw reflection in heading
  Xssmaze.push("errpage-level1", "/errpage/level1/?query=a", "404 error page with raw reflection in h1")
  maze_get "/errpage/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><h1>Page not found: #{query}</h1></body></html>"
  end

  # Level 2: Error message with raw reflection in div
  Xssmaze.push("errpage-level2", "/errpage/level2/?query=a", "error message div with raw reflection")
  maze_get "/errpage/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"error\">Invalid input: #{query}</div></body></html>"
  end

  # Level 3: Debug page with query reflected in <pre> block
  # Break out of pre and inject
  Xssmaze.push("errpage-level3", "/errpage/level3/?query=a", "debug page with reflection in pre tag")
  maze_get "/errpage/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><h2>Debug Info</h2><pre>Request param: #{query}</pre></body></html>"
  end

  # Level 4: Search results page with query in paragraph text
  # Break out of quoted text and inject HTML
  Xssmaze.push("errpage-level4", "/errpage/level4/?query=a", "search results page with reflection in paragraph")
  maze_get "/errpage/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><p>No results for \"#{query}\"</p></body></html>"
  end

  # Level 5: Error page with query in both <title> and <h1>
  # Both contexts are exploitable
  Xssmaze.push("errpage-level5", "/errpage/level5/?query=a", "error page with reflection in title and h1")
  maze_get "/errpage/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Error - #{query}</title></head><body><h1>Error: #{query}</h1></body></html>"
  end

  # Level 6: Stack trace page with query reflected in <code> block
  # Break out of code tag and inject
  Xssmaze.push("errpage-level6", "/errpage/level6/?query=a", "stack trace page with reflection in code tag")
  maze_get "/errpage/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><h2>Application Error</h2><code>NameError: undefined variable '#{query}'</code></body></html>"
  end
end
