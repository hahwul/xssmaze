Xssmaze.push("basic-level1", "/basic/level1/?query=a", "no escape",
  vuln: "reflected-html", delivery: ["query"])
maze_get "/basic/level1/" do |env|
  env.params.query["query"]
end

Xssmaze.push("basic-level2", "/basic/level2/?query=a", "escape to double-quot",
  vuln: "reflected-html", delivery: ["query"], note: "only double quotes are entity-encoded, which the HTML body context does not need")
maze_get "/basic/level2/" do |env|
  Filters.escape_double_quote(env.params.query["query"])
end

Xssmaze.push("basic-level3", "/basic/level3/?query=a", "escape to single-quot",
  vuln: "reflected-html", delivery: ["query"], note: "only single quotes are entity-encoded, which the HTML body context does not need")
maze_get "/basic/level3/" do |env|
  Filters.escape_single_quote(env.params.query["query"])
end

Xssmaze.push("basic-level4", "/basic/level4/?query=a", "escape to all quot",
  vuln: "reflected-html", delivery: ["query"], note: "both quote characters are entity-encoded; angle brackets pass through untouched")
maze_get "/basic/level4/" do |env|
  Filters.escape_quotes(env.params.query["query"])
end

Xssmaze.push("basic-level5", "/basic/level5/?query=a", "escape to parenthesis",
  vuln: "reflected-html", delivery: ["query"], note: "parentheses are stripped, so alert(1) never survives; use a paren-free call such as alert`1`")
maze_get "/basic/level5/" do |env|
  Filters.strip_parens(env.params.query["query"])
end

Xssmaze.push("basic-level6", "/basic/level6/?query=a", "escape to all quot and parenthesis",
  vuln: "reflected-html", delivery: ["query"], note: "quotes are encoded and parentheses stripped; a backtick call such as alert`1` still works")
maze_get "/basic/level6/" do |env|
  query = Filters.escape_quotes(env.params.query["query"])
  Filters.strip_parens(query)
end

Xssmaze.push("basic-level7", "/basic/level7/?query=a", "escape to all quot and parenthesis and backtick",
  vuln: "reflected-html", delivery: ["query"], note: "quotes, parentheses and backticks are all removed, so the call has to come from a handler assignment: <script>onerror=alert;throw 1</script>")
maze_get "/basic/level7/" do |env|
  query = Filters.escape_quotes(env.params.query["query"])
  query = Filters.strip_parens(query)
  query.gsub("`", "")
end
