def load_attribute_context_xss
  # Level 1: Reflection in <input type="text" value="QUERY">
  # Bypass: break out with " onmouseover=alert(1) x="
  Xssmaze.push("attrctx-level1", "/attrctx/level1/?query=a", "reflection in input value attribute (double-quoted)")
  maze_get "/attrctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
  end

  # Level 2: Reflection in <a href="QUERY">
  # Bypass: use javascript:alert(1) protocol
  Xssmaze.push("attrctx-level2", "/attrctx/level2/?query=a", "reflection in href attribute (javascript: protocol)")
  maze_get "/attrctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"#{query}\">Click here</a></body></html>"
  end

  # Level 3: Reflection in <img src="QUERY"> with " encoded to &quot; but ' allowed
  # Bypass: use ' onerror=alert(1) x='
  Xssmaze.push("attrctx-level3", "/attrctx/level3/?query=a", "reflection in img src (double-quote encoded, single-quote allowed)")
  maze_get "/attrctx/level3/" do |env|
    query = Filters.escape_double_quote(env.params.query["query"])

    "<html><body><img src='#{query}'></body></html>"
  end

  # Level 4: Reflection in <div style="color: QUERY">
  # Bypass: break out with " onmouseover=alert(1) x="
  Xssmaze.push("attrctx-level4", "/attrctx/level4/?query=a", "reflection in style attribute (double-quoted)")
  maze_get "/attrctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"color: #{query}\">Hello</div></body></html>"
  end

  # Level 5: Reflection in <iframe src="QUERY">
  # Bypass: use javascript:alert(1)
  Xssmaze.push("attrctx-level5", "/attrctx/level5/?query=a", "reflection in iframe src attribute (javascript: protocol)")
  maze_get "/attrctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><iframe src=\"#{query}\"></iframe></body></html>"
  end

  # Level 6: Reflection in <input type="hidden" value="QUERY">
  # Bypass: break out with " type=text onfocus=alert(1) autofocus x="
  Xssmaze.push("attrctx-level6", "/attrctx/level6/?query=a", "reflection in hidden input value (type override to trigger focus)")
  maze_get "/attrctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><input type=\"hidden\" value=\"#{query}\"></body></html>"
  end
end
