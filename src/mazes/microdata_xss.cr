def load_microdata_xss
  # Level 1: Reflected in <div itemscope itemtype="QUERY">
  # Bypass: break out of itemtype with " then inject event handler
  Xssmaze.push("microdata-level1", "/microdata/level1/?query=a", "reflection in itemtype attribute (double-quoted)")
  maze_get "/microdata/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div itemscope itemtype=\"#{query}\"><span>content</span></div>
    </body></html>"
  end

  # Level 2: Reflected in <span itemprop="QUERY">
  # Bypass: break out of itemprop with " then inject event handler
  Xssmaze.push("microdata-level2", "/microdata/level2/?query=a", "reflection in itemprop attribute (double-quoted)")
  maze_get "/microdata/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div itemscope itemtype=\"https://schema.org/Thing\">
      <span itemprop=\"#{query}\">value</span>
    </div>
    </body></html>"
  end

  # Level 3: Reflected in <meta itemprop="name" content="QUERY">
  # Bypass: break out of content with " then inject event handler
  Xssmaze.push("microdata-level3", "/microdata/level3/?query=a", "reflection in meta itemprop content attribute (double-quoted)")
  maze_get "/microdata/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div itemscope itemtype=\"https://schema.org/Product\">
      <meta itemprop=\"name\" content=\"#{query}\">
      <span>Product Page</span>
    </div>
    </body></html>"
  end

  # Level 4: Reflected in <link itemprop="url" href="QUERY">
  # Bypass: use javascript: protocol or break out with " then inject event handler
  Xssmaze.push("microdata-level4", "/microdata/level4/?query=a", "reflection in link itemprop href attribute (double-quoted)")
  maze_get "/microdata/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div itemscope itemtype=\"https://schema.org/WebPage\">
      <link itemprop=\"url\" href=\"#{query}\">
      <span>Page Info</span>
    </div>
    </body></html>"
  end

  # Level 5: Reflected in <div property="name" content="QUERY"> (RDFa)
  # Bypass: break out of content with " then inject event handler
  Xssmaze.push("microdata-level5", "/microdata/level5/?query=a", "reflection in RDFa property content attribute (double-quoted)")
  maze_get "/microdata/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div vocab=\"https://schema.org/\" typeof=\"Person\">
      <div property=\"name\" content=\"#{query}\">text</div>
    </div>
    </body></html>"
  end

  # Level 6: Reflected in <span typeof="QUERY"> (RDFa)
  # Bypass: break out of typeof with " then inject event handler
  Xssmaze.push("microdata-level6", "/microdata/level6/?query=a", "reflection in RDFa typeof attribute (double-quoted)")
  maze_get "/microdata/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div vocab=\"https://schema.org/\">
      <span typeof=\"#{query}\">content</span>
    </div>
    </body></html>"
  end
end
