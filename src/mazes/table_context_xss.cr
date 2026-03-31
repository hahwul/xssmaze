def load_table_context_xss
  # Level 1: Reflected in <td> inside a table
  Xssmaze.push("tablecontext-level1", "/tablecontext/level1/?query=a", "reflection in td element")
  maze_get "/tablecontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 1</h1>
    <table><tr><td>#{query}</td></tr></table>
    </body></html>"
  end

  # Level 2: Reflected in <th> inside a table
  Xssmaze.push("tablecontext-level2", "/tablecontext/level2/?query=a", "reflection in th element")
  maze_get "/tablecontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 2</h1>
    <table><tr><th>#{query}</th></tr></table>
    </body></html>"
  end

  # Level 3: Reflected in <caption> inside a table
  Xssmaze.push("tablecontext-level3", "/tablecontext/level3/?query=a", "reflection in caption element")
  maze_get "/tablecontext/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 3</h1>
    <table><caption>#{query}</caption><tr><td>data</td></tr></table>
    </body></html>"
  end

  # Level 4: Reflected in <li> inside a <ul>
  Xssmaze.push("tablecontext-level4", "/tablecontext/level4/?query=a", "reflection in li element")
  maze_get "/tablecontext/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 4</h1>
    <ul><li>#{query}</li></ul>
    </body></html>"
  end

  # Level 5: Reflected in <dd> inside a <dl>
  Xssmaze.push("tablecontext-level5", "/tablecontext/level5/?query=a", "reflection in dd element")
  maze_get "/tablecontext/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 5</h1>
    <dl><dt>Term</dt><dd>#{query}</dd></dl>
    </body></html>"
  end

  # Level 6: Reflected in <figcaption> inside a <figure>
  Xssmaze.push("tablecontext-level6", "/tablecontext/level6/?query=a", "reflection in figcaption element")
  maze_get "/tablecontext/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Table Context XSS Level 6</h1>
    <figure><img src=\"/image.png\" alt=\"figure\"><figcaption>#{query}</figcaption></figure>
    </body></html>"
  end
end
