def load_char_limit_filter_xss
  # Level 1: Strips < and > but reflects in input value attribute (double-quoted)
  # Bypass: break out of attribute with " onfocus=alert(1) autofocus "
  Xssmaze.push("charlimit-level1", "/charlimit/level1/?query=a", "strips angle brackets, reflects in input value attribute")
  maze_get "/charlimit/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("<", "").gsub(">", "")

    "<html><body>
    <h1>Char Limit Filter Level 1</h1>
    <form><input type=\"text\" value=\"#{filtered}\"></form>
    </body></html>"
  end

  # Level 2: Strips double quotes but reflects in single-quoted attribute
  # Bypass: break out of single-quoted attribute with '
  Xssmaze.push("charlimit-level2", "/charlimit/level2/?query=a", "strips double quotes, reflects in single-quoted attribute")
  maze_get "/charlimit/level2/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("\"", "")

    "<html><body>
    <h1>Char Limit Filter Level 2</h1>
    <div title='#{filtered}'>Content</div>
    </body></html>"
  end

  # Level 3: Strips single and double quotes but reflects raw in body
  # Bypass: <img src=x onerror=alert(1)> (no quotes needed)
  Xssmaze.push("charlimit-level3", "/charlimit/level3/?query=a", "strips all quotes, reflects raw in body")
  maze_get "/charlimit/level3/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("'", "").gsub("\"", "")

    "<html><body>
    <h1>Char Limit Filter Level 3</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 4: Strips parentheses but reflects raw in body
  # Bypass: backticks <img src=x onerror=alert`1`> or <script>throw onerror=alert,1</script>
  Xssmaze.push("charlimit-level4", "/charlimit/level4/?query=a", "strips parentheses, reflects raw in body")
  maze_get "/charlimit/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("(", "").gsub(")", "")

    "<html><body>
    <h1>Char Limit Filter Level 4</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 5: Strips forward slash but reflects raw in body
  # Bypass: <img src=x onerror=alert(1)> (img is self-closing, no / needed)
  Xssmaze.push("charlimit-level5", "/charlimit/level5/?query=a", "strips forward slash, reflects raw in body")
  maze_get "/charlimit/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("/", "")

    "<html><body>
    <h1>Char Limit Filter Level 5</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 6: Strips equals sign but reflects raw in body
  # Bypass: <script>alert(1)</script> (no = needed)
  Xssmaze.push("charlimit-level6", "/charlimit/level6/?query=a", "strips equals sign, reflects raw in body")
  maze_get "/charlimit/level6/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("=", "")

    "<html><body>
    <h1>Char Limit Filter Level 6</h1>
    <div>#{filtered}</div>
    </body></html>"
  end
end
