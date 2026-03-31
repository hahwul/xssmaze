def load_url_param_context_xss
  # Level 1: Reflection inside <a href> URL query parameter
  # Query is placed as a parameter value inside a double-quoted href attribute.
  # Bypass: break out of href with ", inject event handler, e.g. " onfocus=alert(1) autofocus x="
  Xssmaze.push("url-param-ctx-level1", "/url-param-ctx/level1/?query=a", "reflection in a href URL query parameter value")
  maze_get "/url-param-ctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"https://example.com/search?q=#{query}\">Search link</a></body></html>"
  end

  # Level 2: Reflection inside <form action> URL query parameter
  # Query is placed as a token parameter value inside a double-quoted action attribute.
  # Bypass: break out of action with ", inject event handler, e.g. " onfocus=alert(1) autofocus x="
  Xssmaze.push("url-param-ctx-level2", "/url-param-ctx/level2/?query=a", "reflection in form action URL query parameter value")
  maze_get "/url-param-ctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><form action=\"/submit?token=#{query}\"><input type=\"submit\" value=\"Go\"></form></body></html>"
  end

  # Level 3: Reflection inside <img src> URL query parameter
  # Query is placed as a name parameter value inside a double-quoted src attribute.
  # Bypass: break out of src with ", inject onerror, e.g. " onerror=alert(1) x="
  Xssmaze.push("url-param-ctx-level3", "/url-param-ctx/level3/?query=a", "reflection in img src URL query parameter value")
  maze_get "/url-param-ctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><img src=\"/image?name=#{query}\"></body></html>"
  end

  # Level 4: Reflection inside <link href> URL query parameter
  # Query is placed as a theme parameter value inside a double-quoted href on a link element.
  # Bypass: break out of href with ", inject event handler, e.g. " onload=alert(1) x="
  Xssmaze.push("url-param-ctx-level4", "/url-param-ctx/level4/?query=a", "reflection in link href URL query parameter value")
  maze_get "/url-param-ctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><head><link href=\"/css?theme=#{query}\" rel=\"stylesheet\"></head><body><p>Styled page</p></body></html>"
  end

  # Level 5: Reflection inside <script src> URL query parameter
  # Query is placed as a version parameter value inside a double-quoted src on a script tag.
  # Bypass: break out of src with ", close script tag with ></script>, inject new tag
  Xssmaze.push("url-param-ctx-level5", "/url-param-ctx/level5/?query=a", "reflection in script src URL query parameter value")
  maze_get "/url-param-ctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><script src=\"/js?v=#{query}\"></script></head><body><p>Script loaded</p></body></html>"
  end

  # Level 6: Reflection inside <iframe src> URL query parameter
  # Query is placed as an id parameter value inside a double-quoted src on an iframe.
  # Bypass: break out of src with ", inject event handler, e.g. " onload=alert(1) x="
  Xssmaze.push("url-param-ctx-level6", "/url-param-ctx/level6/?query=a", "reflection in iframe src URL query parameter value")
  maze_get "/url-param-ctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><iframe src=\"/embed?id=#{query}\"></iframe></body></html>"
  end
end
