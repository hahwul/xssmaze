def load_seo_context_xss
  # Level 1: Reflection in og:title meta tag content attribute
  # Bypass: break out of content attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("seoctx-level1", "/seoctx/level1/?query=a", "reflection in og:title meta content attribute")
  maze_get "/seoctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><head><meta property=\"og:title\" content=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 2: Reflection in keywords meta tag content attribute
  # Bypass: break out of content attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("seoctx-level2", "/seoctx/level2/?query=a", "reflection in keywords meta content attribute")
  maze_get "/seoctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><meta name=\"keywords\" content=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 3: Reflection in og:description meta tag content attribute
  # Bypass: break out of content attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("seoctx-level3", "/seoctx/level3/?query=a", "reflection in og:description meta content attribute")
  maze_get "/seoctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><head><meta property=\"og:description\" content=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 4: Reflection in og:url meta tag content attribute
  # Bypass: break out of content attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("seoctx-level4", "/seoctx/level4/?query=a", "reflection in og:url meta content attribute")
  maze_get "/seoctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><head><meta property=\"og:url\" content=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 5: Reflection in canonical link href attribute
  # Bypass: break out of href attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("seoctx-level5", "/seoctx/level5/?query=a", "reflection in canonical link href attribute")
  maze_get "/seoctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><link rel=\"canonical\" href=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 6: Dual reflection - in meta author content AND in body span
  # Bypass: either context is exploitable; body span is easiest with raw HTML injection
  # e.g. <script>alert(1)</script>
  Xssmaze.push("seoctx-level6", "/seoctx/level6/?query=a", "dual reflection in meta author and body span")
  maze_get "/seoctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><head><meta name=\"author\" content=\"#{query}\"></head><body><span class=\"author\">#{query}</span></body></html>"
  end
end
