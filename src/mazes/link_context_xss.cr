# Level 1: Reflected in <a href="QUERY">
Xssmaze.push("linkcontext-level1", "/linkcontext/level1/?query=a", "reflection in a href attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "an anchor href takes a javascript: URL, but that needs a click; a quote breakout does not")
maze_get "/linkcontext/level1/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Link Context XSS Level 1</h1>
  <a href=\"#{query}\" class=\"btn\">Click</a>
  </body></html>"
end

# Level 2: Reflected in <link rel="stylesheet" href="QUERY">
Xssmaze.push("linkcontext-level2", "/linkcontext/level2/?query=a", "reflection in link href attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "a stylesheet href does not run javascript: URLs; break out of the double-quoted attribute")
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
Xssmaze.push("linkcontext-level3", "/linkcontext/level3/?query=a", "reflection in a ping attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "the ping attribute only fires a background POST and never executes; break out of the quote")
maze_get "/linkcontext/level3/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Link Context XSS Level 3</h1>
  <a href=\"/page\" ping=\"#{query}\">Click</a>
  </body></html>"
end

# Level 4: Reflected in <area href="QUERY"> inside <map>
Xssmaze.push("linkcontext-level4", "/linkcontext/level4/?query=a", "reflection in area href attribute inside map",
  vuln: "reflected-attr", delivery: ["query"], note: "the usemap image does not exist, so the area is not clickable; break out of the quoted attribute instead of using a javascript: URL")
maze_get "/linkcontext/level4/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Link Context XSS Level 4</h1>
  <img src=\"/image.png\" usemap=\"#navmap\" alt=\"navigation\">
  <map name=\"navmap\"><area shape=\"rect\" coords=\"0,0,100,100\" href=\"#{query}\"></map>
  </body></html>"
end

# Level 5: Reflected in <base href="QUERY">
Xssmaze.push("linkcontext-level5", "/linkcontext/level5/?query=a", "reflection in base href attribute",
  vuln: "reflected-attr", delivery: ["query"])
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
Xssmaze.push("linkcontext-level6", "/linkcontext/level6/?query=a", "reflection in a title attribute",
  vuln: "reflected-attr", delivery: ["query"])
maze_get "/linkcontext/level6/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Link Context XSS Level 6</h1>
  <a href=\"/page\" title=\"#{query}\">Link</a>
  </body></html>"
end
