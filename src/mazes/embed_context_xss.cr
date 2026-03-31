def load_embed_context_xss
  # Level 1: Reflected in <object data="QUERY" type="text/html">
  # Break out of data attribute with "
  Xssmaze.push("embedctx-level1", "/embedctx/level1/?query=a", "reflection in object data attribute")
  maze_get "/embedctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 1</h1>
    <object data=\"#{query}\" type=\"text/html\" width=\"500\" height=\"300\">Object not supported</object>
    </body></html>"
  end

  # Level 2: Reflected in <embed type="text/html" src="QUERY">
  # Break out of src attribute with "
  Xssmaze.push("embedctx-level2", "/embedctx/level2/?query=a", "reflection in embed src attribute with text/html type")
  maze_get "/embedctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 2</h1>
    <embed type=\"text/html\" src=\"#{query}\">
    </body></html>"
  end

  # Level 3: Reflected in <param name="movie" value="QUERY"> inside <object>
  # Break out of value attribute with "
  Xssmaze.push("embedctx-level3", "/embedctx/level3/?query=a", "reflection in param value inside object tag")
  maze_get "/embedctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 3</h1>
    <object type=\"application/x-shockwave-flash\" width=\"500\" height=\"300\">
      <param name=\"movie\" value=\"#{query}\">
      <param name=\"quality\" value=\"high\">
    </object>
    </body></html>"
  end

  # Level 4: Reflected in <applet code="QUERY"> (deprecated but parsed)
  # Break out of code attribute with "
  Xssmaze.push("embedctx-level4", "/embedctx/level4/?query=a", "reflection in deprecated applet code attribute")
  maze_get "/embedctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 4</h1>
    <applet code=\"#{query}\" width=\"300\" height=\"300\">Applet not supported</applet>
    </body></html>"
  end

  # Level 5: Reflected in <param name="src" value="QUERY"> inside nested <object>
  # Break out of value attribute with "
  Xssmaze.push("embedctx-level5", "/embedctx/level5/?query=a", "reflection in param value inside nested object")
  maze_get "/embedctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 5</h1>
    <object type=\"application/pdf\" width=\"600\" height=\"400\">
      <param name=\"src\" value=\"#{query}\"></param>
      <p>PDF viewer not available</p>
    </object>
    </body></html>"
  end

  # Level 6: Reflected in <embed src="QUERY"> with explicit dimensions
  # Break out of src attribute with "
  Xssmaze.push("embedctx-level6", "/embedctx/level6/?query=a", "reflection in embed src with dimensions")
  maze_get "/embedctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Embed Context XSS Level 6</h1>
    <div class=\"embed-wrapper\">
      <embed src=\"#{query}\" width=\"500\" height=\"300\" type=\"application/pdf\">
    </div>
    </body></html>"
  end
end
