def load_response_split_xss
  # Level 1: Reflection in HTTP header (X-Custom) + body
  Xssmaze.push("rsplit-level1", "/rsplit/level1/?query=a", "reflection in custom header + body")
  maze_get "/rsplit/level1/" do |env|
    query = env.params.query["query"]
    env.response.headers["X-Search-Term"] = query

    "<html><body><h1>Search: #{query}</h1></body></html>"
  end

  # Level 2: Two different params, different contexts
  Xssmaze.push("rsplit-level2", "/rsplit/level2/?name=a&color=blue", "two params: body + style attribute")
  maze_get "/rsplit/level2/" do |env|
    name = env.params.query.fetch("name", "a")
    color = env.params.query.fetch("color", "blue")

    "<html><body><div style=\"color: #{color}\">Hello, #{name}!</div></body></html>"
  end

  # Level 3: Error page reflection (search term in error message)
  Xssmaze.push("rsplit-level3", "/rsplit/level3/?page=test", "error message query reflection")
  maze_get "/rsplit/level3/" do |env|
    page = env.params.query.fetch("page", "unknown")

    "<html><body><h1>Error: Not Found</h1><p>The page '#{page}' was not found on this server.</p></body></html>"
  end

  # Level 4: Reflection in Set-Cookie + body
  Xssmaze.push("rsplit-level4", "/rsplit/level4/?pref=a", "set-cookie + body reflection")
  maze_get "/rsplit/level4/" do |env|
    pref = env.params.query.fetch("pref", "default")
    env.response.cookies << HTTP::Cookie.new("pref", pref, path: "/rsplit/level4/")

    "<html><body><div>Preference: #{pref}</div></body></html>"
  end
end
