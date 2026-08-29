# Level 1: Strips < and > but reflects in input value attribute (double-quoted)
# Bypass: break out of attribute with " onfocus=alert(1) autofocus "
Xssmaze.push("charlimit-level1", "/charlimit/level1/?query=a", "strips angle brackets, reflects in input value attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are stripped; break out of the double-quoted input value and add an event handler")
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
Xssmaze.push("charlimit-level2", "/charlimit/level2/?query=a", "strips double quotes, reflects in single-quoted attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "double quotes are stripped; the title attribute is single-quoted")
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
Xssmaze.push("charlimit-level3", "/charlimit/level3/?query=a", "strips all quotes, reflects raw in body",
  vuln: "reflected-html", delivery: ["query"], note: "both quote characters are stripped, so the payload has to be quote-free: <img src=x onerror=alert(1)>")
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
Xssmaze.push("charlimit-level4", "/charlimit/level4/?query=a", "strips parentheses, reflects raw in body",
  vuln: "reflected-html", delivery: ["query"], note: "parentheses are stripped; use a backtick call such as <img src=x onerror=alert`1`>")
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
Xssmaze.push("charlimit-level5", "/charlimit/level5/?query=a", "strips forward slash, reflects raw in body",
  vuln: "reflected-html", delivery: ["query"], note: "forward slashes are stripped, so no closing tag survives; use a void element such as <img src=x onerror=alert(1)>")
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
Xssmaze.push("charlimit-level6", "/charlimit/level6/?query=a", "strips equals sign, reflects raw in body",
  vuln: "reflected-html", delivery: ["query"], note: "= is stripped, so no attribute takes a value; <script>alert(1)</script> needs none")
maze_get "/charlimit/level6/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub("=", "")

  "<html><body>
  <h1>Char Limit Filter Level 6</h1>
  <div>#{filtered}</div>
  </body></html>"
end
