def load_parser_differential_xss
  # Level 1: Reflection in <noscript> tag (browsers parse differently when JS enabled)
  Xssmaze.push("pdiff-level1", "/pdiff/level1/?query=a", "reflection in <noscript> tag (parser differential with JS enabled)")
  maze_get "/pdiff/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><noscript>#{query}</noscript><p>safe</p></body></html>"
  end

  # Level 2: Reflection after unclosed <select> tag
  Xssmaze.push("pdiff-level2", "/pdiff/level2/?query=a", "reflection after unclosed <select> tag")
  maze_get "/pdiff/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><select><option>#{query}</body></html>"
  end

  # Level 3: Reflection inside <math> tag (MathML namespace)
  Xssmaze.push("pdiff-level3", "/pdiff/level3/?query=a", "reflection inside <math> MathML namespace")
  maze_get "/pdiff/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><math><mi>#{query}</mi></math></body></html>"
  end

  # Level 4: Reflection after unclosed <table> row (foster parenting)
  Xssmaze.push("pdiff-level4", "/pdiff/level4/?query=a", "reflection after unclosed <table> row (foster parenting)")
  maze_get "/pdiff/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><table><tr><td>#{query}</body></html>"
  end

  # Level 5: Reflection inside <xmp> tag (deprecated, preformatted content)
  Xssmaze.push("pdiff-level5", "/pdiff/level5/?query=a", "reflection inside deprecated <xmp> tag")
  maze_get "/pdiff/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><xmp>#{query}</xmp></body></html>"
  end

  # Level 6: Reflection inside <iframe srcdoc="QUERY"> (must break out of attribute)
  Xssmaze.push("pdiff-level6", "/pdiff/level6/?query=a", "reflection inside iframe srcdoc attribute")
  maze_get "/pdiff/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><iframe srcdoc=\"#{query}\"></iframe></body></html>"
  end
end
