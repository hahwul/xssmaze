def load_link_context_xss
  # Level 1: Reflected in <a href="QUERY">
  Xssmaze.push("linkcontext-level1", "/linkcontext/level1/?query=a", "reflection in a href attribute")
  maze_get "/linkcontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Link Context XSS Level 1</h1>
    <a href=\"#{query}\" class=\"btn\">Click</a>
    </body></html>"
  end

  # Level 2: Reflected in <link rel="stylesheet" href="QUERY">
  Xssmaze.push("linkcontext-level2", "/linkcontext/level2/?query=a", "reflection in link href attribute")
  maze_get "/linkcontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <link rel=\"stylesheet\" href=\"#{query}\">
    </head><body>
    <h1>Link Context XSS Level 2</h1>
    <p>Content here</p>
    </body></html>"
  end

  # Level 3: Reflected in <a ping="QUERY">
  Xssmaze.push("linkcontext-level3", "/linkcontext/level3/?query=a", "reflection in a ping attribute")
  maze_get "/linkcontext/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Link Context XSS Level 3</h1>
    <a href=\"/page\" ping=\"#{query}\">Click</a>
    </body></html>"
  end

  # Level 4: Reflected in <area href="QUERY"> inside <map>
  Xssmaze.push("linkcontext-level4", "/linkcontext/level4/?query=a", "reflection in area href attribute inside map")
  maze_get "/linkcontext/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Link Context XSS Level 4</h1>
    <img src=\"/image.png\" usemap=\"#navmap\" alt=\"navigation\">
    <map name=\"navmap\"><area shape=\"rect\" coords=\"0,0,100,100\" href=\"#{query}\"></map>
    </body></html>"
  end

  # Level 5: Reflected in <base href="QUERY">
  Xssmaze.push("linkcontext-level5", "/linkcontext/level5/?query=a", "reflection in base href attribute")
  maze_get "/linkcontext/level5/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <base href=\"#{query}\">
    </head><body>
    <h1>Link Context XSS Level 5</h1>
    <a href=\"/page\">Link</a>
    </body></html>"
  end

  # Level 6: Reflected in <a href="/page" title="QUERY">
  Xssmaze.push("linkcontext-level6", "/linkcontext/level6/?query=a", "reflection in a title attribute")
  maze_get "/linkcontext/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Link Context XSS Level 6</h1>
    <a href=\"/page\" title=\"#{query}\">Link</a>
    </body></html>"
  end
end
