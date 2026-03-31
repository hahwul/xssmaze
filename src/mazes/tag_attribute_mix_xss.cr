def load_tag_attribute_mix_xss
  # Level 1: Query in both tag content and data attribute - either exploitable
  Xssmaze.push("tagattrmix-level1", "/tagattrmix/level1/?query=a", "reflection in both span content and data-info attribute")
  maze_get "/tagattrmix/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div data-info=\"#{query}\"><span>#{query}</span></div></body></html>"
  end

  # Level 2: Query in class attribute - break out with double quote
  Xssmaze.push("tagattrmix-level2", "/tagattrmix/level2/?query=a", "reflection in class attribute (double quote breakout)")
  maze_get "/tagattrmix/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"#{query}\">content</div></body></html>"
  end

  # Level 3: Query in img title attribute - break out with double quote
  Xssmaze.push("tagattrmix-level3", "/tagattrmix/level3/?query=a", "reflection in img title attribute (double quote breakout)")
  maze_get "/tagattrmix/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><img title=\"#{query}\" src=\"photo.jpg\"></body></html>"
  end

  # Level 4: Query in anchor data-id attribute - break out with double quote
  Xssmaze.push("tagattrmix-level4", "/tagattrmix/level4/?query=a", "reflection in anchor data-id attribute (double quote breakout)")
  maze_get "/tagattrmix/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"#\" data-id=\"#{query}\">Link</a></body></html>"
  end

  # Level 5: Query in meta content attribute - break out with double quote
  Xssmaze.push("tagattrmix-level5", "/tagattrmix/level5/?query=a", "reflection in meta content attribute (double quote breakout)")
  maze_get "/tagattrmix/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><meta name=\"description\" content=\"#{query}\"></head><body><p>Page content</p></body></html>"
  end

  # Level 6: Query in div style url() - break out with single quote
  Xssmaze.push("tagattrmix-level6", "/tagattrmix/level6/?query=a", "reflection in style url() with single quote breakout")
  maze_get "/tagattrmix/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"background: url('#{query}')\">Styled content</div></body></html>"
  end
end
