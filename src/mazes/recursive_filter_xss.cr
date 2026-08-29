# Level 1: Strip <script non-recursively (single pass)
Xssmaze.push("recfilt-level1", "/recfilt/level1/?query=a", "strip <script non-recursively (single pass)",
  vuln: "reflected-html", delivery: ["query"], note: "only the literal <script prefix is stripped, in a single pass; every other tag is untouched")
maze_get "/recfilt/level1/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub(/<script/i, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 2: Strip on* event handlers non-recursively
Xssmaze.push("recfilt-level2", "/recfilt/level2/?query=a", "strip on* event handlers non-recursively",
  vuln: "reflected-html", delivery: ["query"], note: "event-handler attributes are stripped, but tags are not")
maze_get "/recfilt/level2/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub(/\bon\w+\s*=/i, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 3: Replace < with empty but only first occurrence
Xssmaze.push("recfilt-level3", "/recfilt/level3/?query=a", "replace first < only",
  vuln: "reflected-html", delivery: ["query"], note: "only the first < is removed; double it")
maze_get "/recfilt/level3/" do |env|
  query = env.params.query["query"]
  filtered = query.sub("<", "")

  "<html><body>#{filtered}</body></html>"
end

# Level 4: Strip javascript: protocol non-recursively, reflect in href
Xssmaze.push("recfilt-level4", "/recfilt/level4/?query=a", "strip javascript: non-recursively in href context",
  vuln: "reflected-attr", delivery: ["query"], note: "javascript: is stripped in a single pass, so javajavascript:script: survives it; the double-quoted href can also just be broken out of")
maze_get "/recfilt/level4/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub(/javascript:/i, "")

  "<html><body><a href=\"#{filtered}\">link</a></body></html>"
end

# Level 5: Double-escape quotes but reflect in JS string (exploitable via </script>)
Xssmaze.push("recfilt-level5", "/recfilt/level5/?query=a", "double-escape quotes in JS string context",
  vuln: "reflected-js", delivery: ["query"], note: "the backslash is not escaped, so a leading backslash neutralises the quote escape; closing the <script> block also works")
maze_get "/recfilt/level5/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub("\"", "\\\"")

  "<html><body>
  <script>var x = \"#{filtered}\";</script>
  </body></html>"
end

# Level 6: Strip parentheses non-recursively (bypass with backtick templates)
Xssmaze.push("recfilt-level6", "/recfilt/level6/?query=a", "strip parentheses non-recursively",
  vuln: "reflected-html", delivery: ["query"], note: "parentheses are stripped from the input, but an entity-encoded paren inside an injected attribute decodes after the filter, and tagged-template syntax needs none at all")
maze_get "/recfilt/level6/" do |env|
  query = env.params.query["query"]
  filtered = query.gsub(/[()]/, "")

  "<html><body>#{filtered}</body></html>"
end
