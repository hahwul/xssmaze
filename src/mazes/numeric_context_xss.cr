def load_numeric_context_xss
  # Level 1: Reflected as raw JS value in script (no quotes around it)
  Xssmaze.push("numericcontext-level1", "/numericcontext/level1/?query=1", "numeric context in script var assignment")
  maze_get "/numericcontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 1</h1>
    <script>var count = #{query};</script>
    <p>Count is set.</p>
    </body></html>"
  end

  # Level 2: Reflected in style z-index attribute value (double-quoted)
  Xssmaze.push("numericcontext-level2", "/numericcontext/level2/?query=1", "numeric context in style z-index attribute")
  maze_get "/numericcontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 2</h1>
    <div style=\"z-index: #{query}\">Content layer</div>
    </body></html>"
  end

  # Level 3: Reflected in input max attribute value (double-quoted)
  Xssmaze.push("numericcontext-level3", "/numericcontext/level3/?query=100", "numeric context in input range max attribute")
  maze_get "/numericcontext/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 3</h1>
    <form><input type=\"range\" min=\"0\" max=\"#{query}\"></form>
    </body></html>"
  end

  # Level 4: Reflected in table border attribute value (double-quoted)
  Xssmaze.push("numericcontext-level4", "/numericcontext/level4/?query=1", "numeric context in table border attribute")
  maze_get "/numericcontext/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 4</h1>
    <table border=\"#{query}\"><tr><td>Cell 1</td><td>Cell 2</td></tr></table>
    </body></html>"
  end

  # Level 5: Reflected in img width attribute value (double-quoted)
  Xssmaze.push("numericcontext-level5", "/numericcontext/level5/?query=200", "numeric context in img width attribute")
  maze_get "/numericcontext/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 5</h1>
    <img width=\"#{query}\" src=\"photo.jpg\" alt=\"photo\">
    </body></html>"
  end

  # Level 6: Reflected as raw JS value in setTimeout delay (no quotes)
  Xssmaze.push("numericcontext-level6", "/numericcontext/level6/?query=1000", "numeric context in setTimeout delay")
  maze_get "/numericcontext/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Numeric Context XSS Level 6</h1>
    <script>setTimeout(function(){}, #{query});</script>
    <p>Timer is set.</p>
    </body></html>"
  end
end
