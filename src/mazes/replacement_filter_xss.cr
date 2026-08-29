# Level 1: Replaces <script> with [removed] (case sensitive)
# Bypass: use uppercase <SCRIPT>, or use <img> / <svg> tags
Xssmaze.push("replacementfilter-level1", "/replacementfilter/level1/?query=a", "case-sensitive <script> replacement",
  vuln: "reflected-html", delivery: ["query"], note: "only the exact lowercase <script> is replaced; <SCRIPT> or <svg onload=alert(1)> passes")
maze_get "/replacementfilter/level1/" do |env|
  query = env.params.query["query"]
  query = query.gsub("<script>", "[removed]")

  "<html><body>#{query}</body></html>"
end

# Level 2: Replaces "alert" with [blocked] (case sensitive)
# Bypass: use confirm(1) or prompt(1) instead
Xssmaze.push("replacementfilter-level2", "/replacementfilter/level2/?query=a", "case-sensitive alert replacement",
  vuln: "reflected-html", delivery: ["query"], note: "the literal lowercase alert is replaced; use confirm(1) or prompt(1)")
maze_get "/replacementfilter/level2/" do |env|
  query = env.params.query["query"]
  query = query.gsub("alert", "[blocked]")

  "<html><body>#{query}</body></html>"
end

# Level 3: Replaces < with ( and > with )
# Reflected inside <input value="QUERY"> — break out of attribute with " then use event handler
Xssmaze.push("replacementfilter-level3", "/replacementfilter/level3/?query=a", "angle brackets replaced, reflected in attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are turned into parentheses, so no tag survives; break out of the double-quoted input value and add an event handler")
maze_get "/replacementfilter/level3/" do |env|
  query = env.params.query["query"]
  query = query.gsub("<", "(").gsub(">", ")")

  "<html><body><input value=\"#{query}\"></body></html>"
end

# Level 4: Replaces "onerror" with empty string (single pass)
# Bypass: "oonnererrorror" becomes "onerror" after removal, or use <script> tag
Xssmaze.push("replacementfilter-level4", "/replacementfilter/level4/?query=a", "single-pass onerror removal",
  vuln: "reflected-html", delivery: ["query"], note: "only onerror is removed, and only in one pass, so oonnererrorror reassembles it; any other handler passes untouched")
maze_get "/replacementfilter/level4/" do |env|
  query = env.params.query["query"]
  query = query.gsub("onerror", "")

  "<html><body>#{query}</body></html>"
end

# Level 5: Replaces <img with empty string (single pass, case insensitive)
# Bypass: "<<img" becomes "<img" after removal, or use <svg>/<script> tags
Xssmaze.push("replacementfilter-level5", "/replacementfilter/level5/?query=a", "single-pass case-insensitive <img removal",
  vuln: "reflected-html", delivery: ["query"], note: "only <img is removed, and only in one pass, so <i<imgmg reassembles it; <svg> and <script> pass untouched")
maze_get "/replacementfilter/level5/" do |env|
  query = env.params.query["query"]
  query = query.gsub(/<img/i, "")

  "<html><body>#{query}</body></html>"
end

# Level 6: Replaces all HTML entities (&...;) with empty string
# Does not affect raw tags — standard injection works fine
Xssmaze.push("replacementfilter-level6", "/replacementfilter/level6/?query=a", "HTML entity removal (raw tags unaffected)",
  vuln: "reflected-html", delivery: ["query"], note: "HTML entities are stripped from the value, so an entity-encoded payload does not survive; raw tags do")
maze_get "/replacementfilter/level6/" do |env|
  query = env.params.query["query"]
  query = query.gsub(/&[a-zA-Z0-9#]+;/, "")

  "<html><body>#{query}</body></html>"
end
