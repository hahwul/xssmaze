def load_form_element_xss
  # Level 1: Reflected in <input placeholder="QUERY">
  Xssmaze.push("formelement-level1", "/formelement/level1/?query=a", "reflection in input placeholder attribute")
  maze_get "/formelement/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 1</h1>
    <form><input type=\"text\" placeholder=\"#{query}\"></form>
    </body></html>"
  end

  # Level 2: Reflected in <textarea placeholder="QUERY">
  Xssmaze.push("formelement-level2", "/formelement/level2/?query=a", "reflection in textarea placeholder attribute")
  maze_get "/formelement/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 2</h1>
    <form><textarea placeholder=\"#{query}\"></textarea></form>
    </body></html>"
  end

  # Level 3: Reflected in <button title="QUERY">
  Xssmaze.push("formelement-level3", "/formelement/level3/?query=a", "reflection in button title attribute")
  maze_get "/formelement/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 3</h1>
    <form><button title=\"#{query}\">Submit</button></form>
    </body></html>"
  end

  # Level 4: Reflected in <select name="QUERY">
  Xssmaze.push("formelement-level4", "/formelement/level4/?query=a", "reflection in select name attribute")
  maze_get "/formelement/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 4</h1>
    <form><select name=\"#{query}\"><option>Option 1</option><option>Option 2</option></select></form>
    </body></html>"
  end

  # Level 5: Reflected in <option value="QUERY">
  Xssmaze.push("formelement-level5", "/formelement/level5/?query=a", "reflection in option value attribute")
  maze_get "/formelement/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 5</h1>
    <form><select><option value=\"#{query}\">Choose</option></select></form>
    </body></html>"
  end

  # Level 6: Reflected in <label for="QUERY">
  Xssmaze.push("formelement-level6", "/formelement/level6/?query=a", "reflection in label for attribute")
  maze_get "/formelement/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Form Element XSS Level 6</h1>
    <form><label for=\"#{query}\">Label</label><input type=\"text\" id=\"field1\"></form>
    </body></html>"
  end
end
