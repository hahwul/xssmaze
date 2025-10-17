def load_svg_xss
  Xssmaze.push("svg-xss-level1", "/svg/level1/?query=a", "SVG onload XSS", "svg-xss")
  get "/svg/level1/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>SVG XSS Level 1</h1>
    <svg onload=\"#{query}\"></svg>
    </body></html>"
  end

  Xssmaze.push("svg-xss-level2", "/svg/level2/?query=a", "SVG animate XSS", "svg-xss")
  get "/svg/level2/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>SVG XSS Level 2</h1>
    <svg><animate attributeName=\"onbegin\" values=\"#{query}\"></animate></svg>
    </body></html>"
  end

  Xssmaze.push("svg-xss-level3", "/svg/level3/?query=a", "SVG foreignObject XSS", "svg-xss")
  get "/svg/level3/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>SVG XSS Level 3</h1>
    <svg><foreignObject><script>#{query}</script></foreignObject></svg>
    </body></html>"
  end

  Xssmaze.push("svg-xss-level4", "/svg/level4/?query=a", "SVG use XSS with href", "svg-xss")
  get "/svg/level4/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>SVG XSS Level 4</h1>
    <svg><use href=\"#{query}\"></use></svg>
    </body></html>"
  end

  Xssmaze.push("svg-xss-level5", "/svg/level5/?query=a", "SVG embedded with data URI", "svg-xss")
  get "/svg/level5/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>SVG XSS Level 5</h1>
    <embed src=\"data:image/svg+xml,<svg onload='#{query}'></svg>\">
    </body></html>"
  end

  Xssmaze.push("svg-xss-level6", "/svg/level6/?query=a", "SVG with filtered script tags", "svg-xss")
  get "/svg/level6/" do |env|
    query = env.params.query["query"].gsub("<script", "").gsub("</script>", "")
    
    "<html><body>
    <h1>SVG XSS Level 6</h1>
    <svg onload=\"#{query}\"></svg>
    </body></html>"
  end
end