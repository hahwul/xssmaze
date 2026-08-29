# Level 1: Reflection in <noscript> tag (browsers parse differently when JS enabled)
Xssmaze.push("pdiff-level1", "/pdiff/level1/?query=a", "reflection in <noscript> tag (parser differential with JS enabled)",
  vuln: "reflected-html", delivery: ["query"], note: "with scripting enabled <noscript> content is raw text, so close </noscript> before the payload can parse")
maze_get "/pdiff/level1/" do |env|
  query = env.params.query["query"]

  "<html><body><noscript>#{query}</noscript><p>safe</p></body></html>"
end

# Level 2: Reflection after unclosed <select> tag
Xssmaze.push("pdiff-level2", "/pdiff/level2/?query=a", "reflection after unclosed <select> tag",
  vuln: "reflected-html", delivery: ["query"], note: "inside <select> the parser drops most tags, but a <script> start tag is still processed")
maze_get "/pdiff/level2/" do |env|
  query = env.params.query["query"]

  "<html><body><select><option>#{query}</body></html>"
end

# Level 3: Reflection inside <math> tag (MathML namespace)
Xssmaze.push("pdiff-level3", "/pdiff/level3/?query=a", "reflection inside <math> MathML namespace",
  vuln: "reflected-html", delivery: ["query"], note: "MathML foreign content: a bare <script> would be created in the MathML namespace and never run, so use an HTML breakout tag such as <img>")
maze_get "/pdiff/level3/" do |env|
  query = env.params.query["query"]

  "<html><body><math><mi>#{query}</mi></math></body></html>"
end

# Level 4: Reflection after unclosed <table> row (foster parenting)
Xssmaze.push("pdiff-level4", "/pdiff/level4/?query=a", "reflection after unclosed <table> row (foster parenting)",
  vuln: "reflected-html", delivery: ["query"], note: "despite the unclosed table the reflection is inside the <td>, an ordinary content context")
maze_get "/pdiff/level4/" do |env|
  query = env.params.query["query"]

  "<html><body><table><tr><td>#{query}</body></html>"
end

# Level 5: Reflection inside <xmp> tag (deprecated, preformatted content)
Xssmaze.push("pdiff-level5", "/pdiff/level5/?query=a", "reflection inside deprecated <xmp> tag",
  vuln: "reflected-html", delivery: ["query"], note: "<xmp> is a raw-text element; close </xmp> first")
maze_get "/pdiff/level5/" do |env|
  query = env.params.query["query"]

  "<html><body><xmp>#{query}</xmp></body></html>"
end

# Level 6: Reflection inside <iframe srcdoc="QUERY"> (must break out of attribute)
Xssmaze.push("pdiff-level6", "/pdiff/level6/?query=a", "reflection inside iframe srcdoc attribute",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "the attribute value is parsed as its own document inside the frame, so a tag payload runs without breaking the attribute")
maze_get "/pdiff/level6/" do |env|
  query = env.params.query["query"]

  "<html><body><iframe srcdoc=\"#{query}\"></iframe></body></html>"
end
