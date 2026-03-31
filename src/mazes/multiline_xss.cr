def load_multiline_xss
  # Level 1: Query reflected raw in <p> tag - standard injection
  Xssmaze.push("multiline-level1", "/multiline/level1/?query=a", "raw reflection in p tag")
  maze_get "/multiline/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Multiline XSS Level 1</h1>
    <p>#{query}</p>
    </body></html>"
  end

  # Level 2: Query reflected in JS string with newlines NOT escaped
  # Bypass: inject newline then </script><img src=x onerror=alert(1)>
  Xssmaze.push("multiline-level2", "/multiline/level2/?query=a", "reflected in JS string, newlines not escaped")
  maze_get "/multiline/level2/" do |env|
    query = env.params.query["query"]
    # Escape quotes but NOT newlines
    escaped = query.gsub("\"", "\\\"")

    "<html><body>
    <h1>Multiline XSS Level 2</h1>
    <script>
    var data = \"#{escaped}\";
    </script>
    </body></html>"
  end

  # Level 3: Query reflected in HTML attribute value with newlines allowed
  # Bypass: " onfocus=alert(1) autofocus "
  Xssmaze.push("multiline-level3", "/multiline/level3/?query=a", "reflected in attribute value, newlines allowed")
  maze_get "/multiline/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Multiline XSS Level 3</h1>
    <input type=\"text\" value=\"#{query}\">
    </body></html>"
  end

  # Level 4: Query reflected inside <textarea> tags
  # Bypass: close textarea with </textarea> then inject
  Xssmaze.push("multiline-level4", "/multiline/level4/?query=a", "reflected inside textarea tags")
  maze_get "/multiline/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Multiline XSS Level 4</h1>
    <textarea>#{query}</textarea>
    </body></html>"
  end

  # Level 5: Query split on newlines, each line wrapped in <li>
  # Bypass: inject HTML in any line
  Xssmaze.push("multiline-level5", "/multiline/level5/?query=a", "split on newlines into li tags")
  maze_get "/multiline/level5/" do |env|
    query = env.params.query["query"]
    lines = query.split("\n")
    items = lines.map { |line| "<li>#{line}</li>" }.join("\n")

    "<html><body>
    <h1>Multiline XSS Level 5</h1>
    <ul>
    #{items}
    </ul>
    </body></html>"
  end

  # Level 6: Query reflected inside <pre> tags
  # Bypass: close pre with </pre> then inject
  Xssmaze.push("multiline-level6", "/multiline/level6/?query=a", "reflected inside pre tags")
  maze_get "/multiline/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Multiline XSS Level 6</h1>
    <pre>#{query}</pre>
    </body></html>"
  end
end
