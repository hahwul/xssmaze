def load_multi_context_xss
  # Level 1: Reflection in textarea (safe) + body (exploitable)
  # Scanner must not stop at safe context; the second reflection is dangerous
  Xssmaze.push("multicontext-level1", "/multicontext/level1/?query=a", "textarea (safe) + body (unsafe) dual reflection")
  maze_get "/multicontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><textarea>#{query}</textarea><div>#{query}</div></body></html>"
  end

  # Level 2: Reflection in title (safe) + img src attribute (exploitable via javascript:)
  Xssmaze.push("multicontext-level2", "/multicontext/level2/?query=a", "title (safe) + attribute URL sink")
  maze_get "/multicontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><title>#{query}</title></head><body><a href=\"#{query}\">Click</a></body></html>"
  end

  # Level 3: Reflection in noscript (safe for JS-enabled) + script context
  Xssmaze.push("multicontext-level3", "/multicontext/level3/?query=a", "noscript + script dual context")
  maze_get "/multicontext/level3/" do |env|
    query = env.params.query["query"]
    escaped = query.gsub("'", "\\'")

    "<html><body><noscript>#{query}</noscript><script>var x='#{escaped}';</script></body></html>"
  end

  # Level 4: Same param in 3 attributes - class (no break), id (no break), onclick (dangerous)
  Xssmaze.push("multicontext-level4", "/multicontext/level4/?query=a", "triple attribute reflection (class + id + onclick)")
  maze_get "/multicontext/level4/" do |env|
    query = Filters.strip_angles(env.params.query["query"])

    "<div class=\"#{query}\" id=\"#{query}\" onclick=\"handle('#{query}')\">Click me</div>"
  end

  # Level 5: Reflection in HTML comment + unquoted attribute
  Xssmaze.push("multicontext-level5", "/multicontext/level5/?query=a", "HTML comment + unquoted attribute reflection")
  maze_get "/multicontext/level5/" do |env|
    query = env.params.query["query"]

    "<!-- #{query} --><input type=text value=#{query}>"
  end

  # Level 6: Two params - one safe in attribute, one unsafe in body
  Xssmaze.push("multicontext-level6", "/multicontext/level6/?q1=a&q2=b", "two params: safe attr + unsafe body")
  maze_get "/multicontext/level6/" do |env|
    q1 = Filters.encode_angles(env.params.query.fetch("q1", "a"))
    q2 = env.params.query.fetch("q2", "b")

    "<html><body><div title=\"#{q1}\">#{q2}</div></body></html>"
  end
end
