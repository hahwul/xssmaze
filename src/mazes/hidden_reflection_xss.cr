def load_hidden_reflection_xss
  # Level 1: Reflected in hidden input — change type, add autofocus/onfocus
  Xssmaze.push("hidden-reflection-level1", "/hidden-reflection/level1/?query=a", "reflection in hidden input (type override)")
  maze_get "/hidden-reflection/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><form><input type=\"hidden\" name=\"token\" value=\"#{query}\"></form></body></html>"
  end

  # Level 2: Reflected in meta refresh URL — close attribute, inject tag
  Xssmaze.push("hidden-reflection-level2", "/hidden-reflection/level2/?query=a", "reflection in meta refresh URL")
  maze_get "/hidden-reflection/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><meta http-equiv=\"refresh\" content=\"0;url=#{query}\"></head><body>Redirecting...</body></html>"
  end

  # Level 3: Reflected in img data-original attribute — break out of attribute
  Xssmaze.push("hidden-reflection-level3", "/hidden-reflection/level3/?query=a", "reflection in img data-original attribute")
  maze_get "/hidden-reflection/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><img src=\"safe.jpg\" data-original=\"#{query}\" alt=\"image\"></body></html>"
  end

  # Level 4: Reflected in application/json script block — close script tag to break out
  Xssmaze.push("hidden-reflection-level4", "/hidden-reflection/level4/?query=a", "reflection in JSON script block (close script tag)")
  maze_get "/hidden-reflection/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><script type=\"application/json\">{\"search\":\"#{query}\",\"page\":1}</script><div>Results</div></body></html>"
  end

  # Level 5: Reflected in CSS style block — close style tag to break out
  Xssmaze.push("hidden-reflection-level5", "/hidden-reflection/level5/?query=a", "reflection in CSS style block (close style tag)")
  maze_get "/hidden-reflection/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><style>.highlight { color: #{query} }</style></head><body><div class=\"highlight\">Text</div></body></html>"
  end

  # Level 6: Reflected inside noscript tag — close noscript to inject
  Xssmaze.push("hidden-reflection-level6", "/hidden-reflection/level6/?query=a", "reflection in noscript tag (close noscript to inject)")
  maze_get "/hidden-reflection/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><noscript><div>JavaScript is disabled. Search: #{query}</div></noscript><div>Content</div></body></html>"
  end
end
