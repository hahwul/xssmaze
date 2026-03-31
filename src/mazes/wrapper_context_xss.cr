def load_wrapper_context_xss
  # Level 1: Query wrapped in <b> and <i> tags - standard injection
  Xssmaze.push("wrappercontext-level1", "/wrappercontext/level1/?query=a", "reflection wrapped in bold+italic tags")
  maze_get "/wrappercontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><b><i>#{query}</i></b></body></html>"
  end

  # Level 2: Query wrapped in <span style="color:red"> - standard injection
  Xssmaze.push("wrappercontext-level2", "/wrappercontext/level2/?query=a", "reflection wrapped in styled span")
  maze_get "/wrappercontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><span style=\"color:red\">#{query}</span></body></html>"
  end

  # Level 3: Query wrapped in <a href="#"> - inject tags within link text
  Xssmaze.push("wrappercontext-level3", "/wrappercontext/level3/?query=a", "reflection wrapped in anchor tag text")
  maze_get "/wrappercontext/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"#\">#{query}</a></body></html>"
  end

  # Level 4: Query wrapped in <small><em> - standard injection
  Xssmaze.push("wrappercontext-level4", "/wrappercontext/level4/?query=a", "reflection wrapped in small+em tags")
  maze_get "/wrappercontext/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><small><em>#{query}</em></small></body></html>"
  end

  # Level 5: Query wrapped in <mark> - standard injection
  Xssmaze.push("wrappercontext-level5", "/wrappercontext/level5/?query=a", "reflection wrapped in mark tag")
  maze_get "/wrappercontext/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><mark>#{query}</mark></body></html>"
  end

  # Level 6: Query wrapped in <abbr title="abbreviation"> - standard injection
  Xssmaze.push("wrappercontext-level6", "/wrappercontext/level6/?query=a", "reflection wrapped in abbr tag")
  maze_get "/wrappercontext/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><abbr title=\"abbreviation\">#{query}</abbr></body></html>"
  end
end
