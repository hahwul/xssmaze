Xssmaze.push("svg-xss-level1", "/svg/level1/?query=a", "SVG onload XSS",
  vuln: "reflected-attr", delivery: ["query"], note: "lands directly in an svg onload handler; the value runs as JS on load, no breakout needed")
maze_get "/svg/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>SVG XSS Level 1</h1>
  <svg onload=\"#{query}\"></svg>
  </body></html>"
end

Xssmaze.push("svg-xss-level2", "/svg/level2/?query=a", "SVG animate XSS",
  vuln: "reflected-attr", delivery: ["query"], note: "reflected into an svg <animate> values attribute; break out of the double-quoted value")
maze_get "/svg/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>SVG XSS Level 2</h1>
  <svg><animate attributeName=\"onbegin\" values=\"#{query}\"></animate></svg>
  </body></html>"
end

Xssmaze.push("svg-xss-level3", "/svg/level3/?query=a", "SVG foreignObject XSS",
  vuln: "reflected-js", delivery: ["query"], note: "reflected raw as the body of a <script> inside <foreignObject>; injected JS executes directly")
maze_get "/svg/level3/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>SVG XSS Level 3</h1>
  <svg><foreignObject><script>#{query}</script></foreignObject></svg>
  </body></html>"
end

Xssmaze.push("svg-xss-level4", "/svg/level4/?query=a", "SVG use XSS with href",
  vuln: "reflected-attr", delivery: ["query"], note: "svg <use> href; break out of the double-quoted attribute")
maze_get "/svg/level4/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>SVG XSS Level 4</h1>
  <svg><use href=\"#{query}\"></use></svg>
  </body></html>"
end

Xssmaze.push("svg-xss-level5", "/svg/level5/?query=a", "SVG embedded with data URI",
  vuln: "reflected-attr", delivery: ["query"], note: "lands in a single-quoted svg onload inside a data:image/svg+xml embed; runs as JS on load")
maze_get "/svg/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>SVG XSS Level 5</h1>
  <embed src=\"data:image/svg+xml,<svg onload='#{query}'></svg>\">
  </body></html>"
end

Xssmaze.push("svg-xss-level6", "/svg/level6/?query=a", "SVG with filtered script tags",
  vuln: "reflected-attr", delivery: ["query"], note: "<script> tags are stripped, but the value lands in an svg onload handler, so inject JS directly")
maze_get "/svg/level6/" do |env|
  query = env.params.query.fetch("query", "").gsub("<script", "").gsub("</script>", "")

  "<html><body>
  <h1>SVG XSS Level 6</h1>
  <svg onload=\"#{query}\"></svg>
  </body></html>"
end
