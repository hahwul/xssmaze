Xssmaze.push("inattr-xss-level1", "/inattr/level1/?query=a", "inattr-xss (double quote)",
  vuln: "reflected-attr", delivery: ["query"])
maze_get "/inattr/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<div class=\"#{query}\">Hello</div>"
end

Xssmaze.push("inattr-xss-level2", "/inattr/level2/?query=a", "inattr-xss (single quote)",
  vuln: "reflected-attr", delivery: ["query"], note: "the class attribute is single-quoted")
maze_get "/inattr/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<div class='#{query}'>Hello</div>"
end

Xssmaze.push("inattr-xss-level3", "/inattr/level3/?query=a", "inattr-xss (double quote with <> filter)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are stripped; break out of the double-quoted attribute and add an event handler instead of a tag")
maze_get "/inattr/level3/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))

  "<div class=\"#{query}\">Hello</div>"
end

Xssmaze.push("inattr-xss-level4", "/inattr/level4/?query=a", "inattr-xss (single quote with <> filter)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are stripped; break out of the single-quoted attribute and add an event handler instead of a tag")
maze_get "/inattr/level4/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))

  "<div class='#{query}'>Hello</div>"
end

Xssmaze.push("inattr-xss-level5", "/inattr/level5/?query=a", "inattr-xss (double quote with <> and blank filter)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets and literal spaces are stripped; separate the injected attribute with a tab or newline")
maze_get "/inattr/level5/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))
  query = Filters.strip_spaces(query)

  "<div class=\"#{query}\">Hello</div>"
end

Xssmaze.push("inattr-xss-level6", "/inattr/level6/?query=a", "inattr-xss (single quote with <> and blank filter)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets and literal spaces are stripped; separate the injected attribute with a tab or newline")
maze_get "/inattr/level6/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))
  query = Filters.strip_spaces(query)

  "<div class='#{query}'>Hello</div>"
end
