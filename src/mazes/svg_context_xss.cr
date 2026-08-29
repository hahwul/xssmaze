# Level 1: Full SVG document with query reflected in <text> element
# Bypass: inject SVG event handler, e.g. </text><svg onload=alert(1)>
Xssmaze.push("svgctx-level1", "/svgctx/level1/?query=a", "SVG text element injection (break out and inject onload)",
  vuln: "reflected-html", delivery: ["query"], note: "the reflection sits in SVG foreign content; close </text> before injecting")
maze_get "/svgctx/level1/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 1</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"200\">
    <rect width=\"400\" height=\"200\" fill=\"#eee\"/>
    <text x=\"10\" y=\"100\" font-size=\"16\">#{query}</text>
  </svg>
  </body></html>"
end

# Level 2: SVG <desc> element with query reflected
# Bypass: </desc><svg onload=alert(1)>
Xssmaze.push("svgctx-level2", "/svgctx/level2/?query=a", "SVG desc element injection (break out of desc)",
  vuln: "reflected-html", delivery: ["query"], note: "SVG <desc> holds parsed content; close </desc> before injecting")
maze_get "/svgctx/level2/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 2</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"200\">
    <desc>#{query}</desc>
    <rect width=\"400\" height=\"200\" fill=\"#ddd\"/>
  </svg>
  </body></html>"
end

# Level 3: SVG <title> element with query reflected
# Bypass: </title><svg onload=alert(1)>
Xssmaze.push("svgctx-level3", "/svgctx/level3/?query=a", "SVG title element injection (break out of title)",
  vuln: "reflected-html", delivery: ["query"], note: "this is the SVG <title>, not the document title; close </title> before injecting")
maze_get "/svgctx/level3/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 3</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"200\">
    <title>#{query}</title>
    <rect width=\"400\" height=\"200\" fill=\"#ccc\"/>
  </svg>
  </body></html>"
end

# Level 4: SVG <a> with query in xlink:href attribute
# Bypass: javascript:alert(1)
Xssmaze.push("svgctx-level4", "/svgctx/level4/?query=a", "SVG xlink:href attribute injection (javascript: protocol)",
  vuln: "reflected-attr", delivery: ["query"], note: "an SVG anchor takes a javascript: URL, but that needs a click; a quote breakout does not")
maze_get "/svgctx/level4/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 4</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"400\" height=\"200\">
    <a xlink:href=\"#{query}\">
      <text x=\"10\" y=\"100\" font-size=\"16\">Click here</text>
    </a>
  </svg>
  </body></html>"
end

# Level 5: SVG <foreignObject> with query reflected in HTML inside it
# Bypass: standard HTML injection, e.g. <img src=x onerror=alert(1)>
Xssmaze.push("svgctx-level5", "/svgctx/level5/?query=a", "SVG foreignObject HTML injection",
  vuln: "reflected-html", delivery: ["query"], note: "inside foreignObject the content is ordinary XHTML, so a plain HTML payload works with no SVG-specific tricks")
maze_get "/svgctx/level5/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 5</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"200\">
    <foreignObject x=\"10\" y=\"10\" width=\"380\" height=\"180\">
      <div xmlns=\"http://www.w3.org/1999/xhtml\">
        <p>Result: #{query}</p>
      </div>
    </foreignObject>
  </svg>
  </body></html>"
end

# Level 6: SVG <animate> with query in values attribute
# Bypass: break out of attribute, e.g. "><svg onload=alert(1)>
Xssmaze.push("svgctx-level6", "/svgctx/level6/?query=a", "SVG animate values attribute injection (break out of attribute)",
  vuln: "reflected-attr", delivery: ["query"])
maze_get "/svgctx/level6/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>SVG Context Level 6</h1>
  <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"200\">
    <rect width=\"100\" height=\"100\" fill=\"blue\">
      <animate attributeName=\"x\" values=\"#{query}\" dur=\"3s\" repeatCount=\"indefinite\"/>
    </rect>
  </svg>
  </body></html>"
end
