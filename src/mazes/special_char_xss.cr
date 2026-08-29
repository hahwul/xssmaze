# Level 1: Server strips backslashes, reflects in body
Xssmaze.push("specialchar-level1", "/specialchar/level1/?query=a", "strips backslashes then reflects in body",
  vuln: "reflected-html", delivery: ["query"], note: "backslashes are stripped; nothing else is")
maze_get "/specialchar/level1/" do |env|
  query = env.params.query["query"].gsub("\\", "")

  "<html><body>
  <h1>Special Char XSS Level 1</h1>
  <div>#{query}</div>
  </body></html>"
end

# Level 2: Server strips semicolons, reflects in body
Xssmaze.push("specialchar-level2", "/specialchar/level2/?query=a", "strips semicolons then reflects in body",
  vuln: "reflected-html", delivery: ["query"], note: "semicolons are stripped, which breaks HTML entities but not a plain tag payload")
maze_get "/specialchar/level2/" do |env|
  query = env.params.query["query"].gsub(";", "")

  "<html><body>
  <h1>Special Char XSS Level 2</h1>
  <div>#{query}</div>
  </body></html>"
end

# Level 3: Server strips colons, reflects in body
Xssmaze.push("specialchar-level3", "/specialchar/level3/?query=a", "strips colons then reflects in body",
  vuln: "reflected-html", delivery: ["query"], note: "colons are stripped, which kills javascript: but not a tag payload")
maze_get "/specialchar/level3/" do |env|
  query = env.params.query["query"].gsub(":", "")

  "<html><body>
  <h1>Special Char XSS Level 3</h1>
  <div>#{query}</div>
  </body></html>"
end

# Level 4: Server URL-decodes input then reflects raw
Xssmaze.push("specialchar-level4", "/specialchar/level4/?query=a", "URL-decodes input then reflects raw",
  vuln: "reflected-html", delivery: ["query"], note: "the value is URL-decoded a second time server-side, so %3Cscript%3E also reaches the sink")
maze_get "/specialchar/level4/" do |env|
  raw_query = env.params.query["query"]
  decoded = URI.decode(raw_query)

  "<html><body>
  <h1>Special Char XSS Level 4</h1>
  <div>#{decoded}</div>
  </body></html>"
end

# Level 5: Server double-URL-decodes input then reflects raw
Xssmaze.push("specialchar-level5", "/specialchar/level5/?query=a", "double URL-decodes input then reflects raw",
  vuln: "reflected-html", delivery: ["query"], note: "the value is URL-decoded twice more server-side, so a double-encoded payload also reaches the sink")
maze_get "/specialchar/level5/" do |env|
  raw_query = env.params.query["query"]
  decoded = URI.decode(URI.decode(raw_query))

  "<html><body>
  <h1>Special Char XSS Level 5</h1>
  <div>#{decoded}</div>
  </body></html>"
end

# Level 6: Server strips null bytes only, reflects raw
Xssmaze.push("specialchar-level6", "/specialchar/level6/?query=a", "strips null bytes then reflects raw",
  vuln: "reflected-html", delivery: ["query"], note: "only NUL bytes are stripped")
maze_get "/specialchar/level6/" do |env|
  query = env.params.query["query"].gsub("\u{0}", "")

  "<html><body>
  <h1>Special Char XSS Level 6</h1>
  <div>#{query}</div>
  </body></html>"
end
