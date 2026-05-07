def load_srcset_xss
  Xssmaze.push("srcset-level1", "/srcset/level1/?query=a", "<img srcset> raw reflection (multi-candidate)")
  maze_get "/srcset/level1/" do |env|
    query = env.params.query["query"]
    "<img srcset='#{query}'>"
  end

  Xssmaze.push("srcset-level2", "/srcset/level2/?query=a", "<source srcset> inside <picture>")
  maze_get "/srcset/level2/" do |env|
    query = env.params.query["query"]
    "<picture><source srcset='#{query}'><img src='/fallback.png'></picture>"
  end

  Xssmaze.push("srcset-level3", "/srcset/level3/?query=a", "<img srcset> with comma-strip filter (descriptor bypass)")
  maze_get "/srcset/level3/" do |env|
    query = env.params.query["query"].gsub(",", "")
    "<img srcset='#{query} 1x'>"
  end

  Xssmaze.push("srcset-level4", "/srcset/level4/?query=a", "imageSrcset on <link rel=preload>")
  maze_get "/srcset/level4/" do |env|
    query = env.params.query["query"]
    "<link rel='preload' as='image' imagesrcset='#{query}'>"
  end
end
