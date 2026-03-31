def load_global_attr_xss
  # Level 1: Reflected in <div id="QUERY">
  # Break out of id attribute with "
  Xssmaze.push("globalattr-level1", "/globalattr/level1/?query=a", "reflection in div id attribute")
  maze_get "/globalattr/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 1</h1>
    <div id=\"#{query}\">content</div>
    </body></html>"
  end

  # Level 2: Reflected in <p class="QUERY">
  # Break out of class attribute with "
  Xssmaze.push("globalattr-level2", "/globalattr/level2/?query=a", "reflection in p class attribute")
  maze_get "/globalattr/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 2</h1>
    <p class=\"#{query}\">text</p>
    </body></html>"
  end

  # Level 3: Reflected in <span accesskey="QUERY">
  # Break out of accesskey attribute with "
  Xssmaze.push("globalattr-level3", "/globalattr/level3/?query=a", "reflection in span accesskey attribute")
  maze_get "/globalattr/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 3</h1>
    <span tabindex=\"0\" accesskey=\"#{query}\">text</span>
    </body></html>"
  end

  # Level 4: Reflected in <div spellcheck="QUERY">
  # Break out of spellcheck attribute with "
  Xssmaze.push("globalattr-level4", "/globalattr/level4/?query=a", "reflection in div spellcheck attribute")
  maze_get "/globalattr/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 4</h1>
    <div contenteditable=\"true\" spellcheck=\"#{query}\">text</div>
    </body></html>"
  end

  # Level 5: Reflected in <p draggable="QUERY">
  # Break out of draggable attribute with "
  Xssmaze.push("globalattr-level5", "/globalattr/level5/?query=a", "reflection in p draggable attribute")
  maze_get "/globalattr/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 5</h1>
    <p draggable=\"#{query}\">text</p>
    </body></html>"
  end

  # Level 6: Reflected in <div lang="QUERY">
  # Break out of lang attribute with "
  Xssmaze.push("globalattr-level6", "/globalattr/level6/?query=a", "reflection in div lang attribute")
  maze_get "/globalattr/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Global Attribute XSS Level 6</h1>
    <div lang=\"#{query}\" dir=\"ltr\">text</div>
    </body></html>"
  end
end
