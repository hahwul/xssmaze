def load_srcset_xss
  # NOTE: srcset/imagesrcset URLs do not by themselves execute JS - the XSS
  # in these levels is plain attribute-context injection (the user closes the
  # quote and adds onerror=). The category exists so scanners can verify they
  # spot reflection inside these specific image-loading attributes.

  Xssmaze.push("srcset-level1", "/srcset/level1/?query=a", "attribute-context injection in <img srcset> (multi-candidate)")
  maze_get "/srcset/level1/" do |env|
    query = env.params.query["query"]
    "<img srcset='#{query}'>"
  end

  Xssmaze.push("srcset-level2", "/srcset/level2/?query=a", "attribute-context injection in <source srcset> inside <picture>")
  maze_get "/srcset/level2/" do |env|
    query = env.params.query["query"]
    "<picture><source srcset='#{query}'><img src='/fallback.png'></picture>"
  end

  Xssmaze.push("srcset-level3", "/srcset/level3/?query=a", "attribute-context injection with comma stripped (descriptor bypass)")
  maze_get "/srcset/level3/" do |env|
    query = env.params.query["query"].gsub(",", "")
    "<img srcset='#{query} 1x'>"
  end

  Xssmaze.push("srcset-level4", "/srcset/level4/?query=a", "attribute-context injection on <link rel=preload imagesrcset>")
  maze_get "/srcset/level4/" do |env|
    query = env.params.query["query"]
    "<link rel='preload' as='image' imagesrcset='#{query}'>"
  end
end
