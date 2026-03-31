def load_list_iteration_xss
  # Level 1: Query split by comma, each part rendered in <li>
  Xssmaze.push("listiteration-level1", "/listiteration/level1/?query=apple,banana,cherry", "list iteration split by comma into li elements")
  maze_get "/listiteration/level1/" do |env|
    query = env.params.query["query"]
    parts = query.split(",")
    items = parts.map { |part| "<li>#{part}</li>" }.join("\n    ")

    "<html><body>
    <h1>List Iteration XSS Level 1</h1>
    <ul>
    #{items}
    </ul>
    </body></html>"
  end

  # Level 2: Query split by pipe, each part rendered in <td>
  Xssmaze.push("listiteration-level2", "/listiteration/level2/?query=col1|col2|col3", "list iteration split by pipe into td elements")
  maze_get "/listiteration/level2/" do |env|
    query = env.params.query["query"]
    parts = query.split("|")
    cells = parts.map { |part| "<td>#{part}</td>" }.join("")

    "<html><body>
    <h1>List Iteration XSS Level 2</h1>
    <table border=\"1\"><tr>#{cells}</tr></table>
    </body></html>"
  end

  # Level 3: Query split by newline (%0A), each part rendered in <p>
  Xssmaze.push("listiteration-level3", "/listiteration/level3/?query=line1%0Aline2%0Aline3", "list iteration split by newline into p elements")
  maze_get "/listiteration/level3/" do |env|
    query = env.params.query["query"]
    parts = query.split("\n")
    paragraphs = parts.map { |part| "<p>#{part}</p>" }.join("\n    ")

    "<html><body>
    <h1>List Iteration XSS Level 3</h1>
    #{paragraphs}
    </body></html>"
  end

  # Level 4: Query split by space, each part rendered in <span class="tag">
  Xssmaze.push("listiteration-level4", "/listiteration/level4/?query=red+green+blue", "list iteration split by space into span tags")
  maze_get "/listiteration/level4/" do |env|
    query = env.params.query["query"]
    parts = query.split(" ")
    spans = parts.map { |part| "<span class=\"tag\">#{part}</span>" }.join(" ")

    "<html><body>
    <h1>List Iteration XSS Level 4</h1>
    <div class=\"tags\">#{spans}</div>
    </body></html>"
  end

  # Level 5: Query split by semicolon, each part in <option value="PART">PART</option>
  Xssmaze.push("listiteration-level5", "/listiteration/level5/?query=opt1;opt2;opt3", "list iteration split by semicolon into option elements")
  maze_get "/listiteration/level5/" do |env|
    query = env.params.query["query"]
    parts = query.split(";")
    options = parts.map { |part| "<option value=\"#{part}\">#{part}</option>" }.join("\n    ")

    "<html><body>
    <h1>List Iteration XSS Level 5</h1>
    <form><select>
    #{options}
    </select></form>
    </body></html>"
  end

  # Level 6: Single dynamic item among 20 static items in a list
  Xssmaze.push("listiteration-level6", "/listiteration/level6/?query=a", "single dynamic item among 20 static li elements")
  maze_get "/listiteration/level6/" do |env|
    query = env.params.query["query"]
    static_items = (1..20).map { |i| "<li>Static Item #{i}</li>" }.join("\n    ")

    "<html><body>
    <h1>List Iteration XSS Level 6</h1>
    <ul>
    #{static_items}
    <li>#{query}</li>
    </ul>
    </body></html>"
  end
end
