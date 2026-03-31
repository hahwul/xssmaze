def load_special_tag_xss
  # Level 1: Reflection inside <option> tag value
  Xssmaze.push("specialtag-level1", "/specialtag/level1/?query=a", "reflection in option value attribute")
  maze_get "/specialtag/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><select><option value=\"#{query}\">Choose</option></select></body></html>"
  end

  # Level 2: Reflection inside <meta> tag content
  Xssmaze.push("specialtag-level2", "/specialtag/level2/?query=a", "reflection in meta tag content")
  maze_get "/specialtag/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><meta name=\"description\" content=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 3: Reflection inside <button> with value attribute
  Xssmaze.push("specialtag-level3", "/specialtag/level3/?query=a", "button value attribute (formaction possible)")
  maze_get "/specialtag/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><form><button type=\"submit\" value=\"#{query}\">Submit</button></form></body></html>"
  end

  # Level 4: Reflection in <base> tag href
  Xssmaze.push("specialtag-level4", "/specialtag/level4/?query=a", "base tag href injection")
  maze_get "/specialtag/level4/" do |env|
    query = env.params.query["query"]

    "<html><head><base href=\"#{query}\"></head><body><a href=\"/test\">Link</a></body></html>"
  end

  # Level 5: Input in <img> alt attribute (< > stripped, attribute breakout possible)
  Xssmaze.push("specialtag-level5", "/specialtag/level5/?query=a", "img alt attribute (angle stripped)")
  maze_get "/specialtag/level5/" do |env|
    query = Filters.strip_angles(env.params.query["query"])

    "<html><body><img src=\"/logo.png\" alt=\"#{query}\"></body></html>"
  end

  # Level 6: Reflection in srcdoc attribute of iframe
  Xssmaze.push("specialtag-level6", "/specialtag/level6/?query=a", "iframe srcdoc attribute injection")
  maze_get "/specialtag/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><iframe srcdoc=\"#{query}\"></iframe></body></html>"
  end

  # Level 7: Reflection in <object> data attribute
  Xssmaze.push("specialtag-level7", "/specialtag/level7/?query=a", "object data attribute injection")
  maze_get "/specialtag/level7/" do |env|
    query = env.params.query["query"]

    "<html><body><object data=\"#{query}\" type=\"text/html\"></object></body></html>"
  end

  # Level 8: Reflection in unquoted img src (space-terminated)
  Xssmaze.push("specialtag-level8", "/specialtag/level8/?query=a", "unquoted src attribute injection")
  maze_get "/specialtag/level8/" do |env|
    query = env.params.query["query"]

    "<html><body><img src=#{query} alt=image></body></html>"
  end
end
