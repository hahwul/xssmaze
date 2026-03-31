def load_boolean_attr_xss
  # Level 1: Reflected in checkbox checked attribute value (double-quoted)
  Xssmaze.push("booleanattr-level1", "/booleanattr/level1/?query=true", "boolean attr context in checkbox checked")
  maze_get "/booleanattr/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 1</h1>
    <form><input type=\"checkbox\" checked=\"#{query}\"> Accept terms</form>
    </body></html>"
  end

  # Level 2: Reflected in select multiple attribute value (double-quoted)
  Xssmaze.push("booleanattr-level2", "/booleanattr/level2/?query=true", "boolean attr context in select multiple")
  maze_get "/booleanattr/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 2</h1>
    <form><select multiple=\"#{query}\"><option>Option A</option><option>Option B</option></select></form>
    </body></html>"
  end

  # Level 3: Reflected in input readonly attribute value (double-quoted)
  Xssmaze.push("booleanattr-level3", "/booleanattr/level3/?query=true", "boolean attr context in input readonly")
  maze_get "/booleanattr/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 3</h1>
    <form><input type=\"text\" readonly=\"#{query}\" value=\"Read only field\"></form>
    </body></html>"
  end

  # Level 4: Reflected in button disabled attribute value (double-quoted)
  Xssmaze.push("booleanattr-level4", "/booleanattr/level4/?query=true", "boolean attr context in button disabled")
  maze_get "/booleanattr/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 4</h1>
    <form><button disabled=\"#{query}\">Submit</button></form>
    </body></html>"
  end

  # Level 5: Reflected in details open attribute value (double-quoted)
  Xssmaze.push("booleanattr-level5", "/booleanattr/level5/?query=true", "boolean attr context in details open")
  maze_get "/booleanattr/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 5</h1>
    <details open=\"#{query}\"><summary>Info</summary><p>Detailed content here.</p></details>
    </body></html>"
  end

  # Level 6: Reflected in input autofocus attribute value (double-quoted)
  Xssmaze.push("booleanattr-level6", "/booleanattr/level6/?query=true", "boolean attr context in input autofocus")
  maze_get "/booleanattr/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Boolean Attr XSS Level 6</h1>
    <form><input autofocus=\"#{query}\" type=\"text\" placeholder=\"Enter text\"></form>
    </body></html>"
  end
end
