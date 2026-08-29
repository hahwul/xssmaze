# Level 1: Regex strips <script[^>]*>.*?</script> (non-greedy) - use <img> tags instead
Xssmaze.push("regexfilt-level1", "/regexfilt/level1/?query=a", "regex strips script tags (non-greedy), use img/svg instead",
  vuln: "reflected-html", delivery: ["query"], note: "the pattern only removes a complete <script>...</script> pair, so another tag survives")
maze_get "/regexfilt/level1/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/<script[^>]*>.*?<\/script>/im, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 2: Regex strips on\w+\s*= (event handlers with optional space) - use <script> instead
Xssmaze.push("regexfilt-level2", "/regexfilt/level2/?query=a", "regex strips event handlers (on*=), use script tags instead",
  vuln: "reflected-html", delivery: ["query"], note: "on...= handlers are stripped, so use a tag that needs none")
maze_get "/regexfilt/level2/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/on\w+\s*=/i, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 3: Regex strips <(script|img|svg|iframe)[^>]*> - use other tags like details, body, input
Xssmaze.push("regexfilt-level3", "/regexfilt/level3/?query=a", "regex strips script/img/svg/iframe tags, use other tags",
  vuln: "reflected-html", delivery: ["query"], note: "only script/img/svg/iframe openers are stripped; other tags survive")
maze_get "/regexfilt/level3/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/<(script|img|svg|iframe)[^>]*>/i, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 4: Regex strips javascript: (case insensitive), reflected in href - break out of href
Xssmaze.push("regexfilt-level4", "/regexfilt/level4/?query=a", "regex strips javascript: in href, break out of attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "javascript: is stripped from the href, so break out of the double-quoted attribute instead")
maze_get "/regexfilt/level4/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/javascript:/i, "")

  "<html><body><a href=\"#{filtered}\">Click here</a></body></html>"
end

# Level 5: Regex strips known tags (script,img,svg,iframe,object,embed) - use video, details, etc.
Xssmaze.push("regexfilt-level5", "/regexfilt/level5/?query=a", "whitelist-style tag stripping, use unlisted tags",
  vuln: "reflected-html", delivery: ["query"], note: "six tag names are stripped in both open and close form; unlisted tags survive")
maze_get "/regexfilt/level5/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/<\/?(script|img|svg|iframe|object|embed)[^>]*>/i, "")

  "<html><body>#{filtered}</body></html>"
end

# Level 6: Regex replaces alert with _alert_ - use confirm/prompt/other functions
Xssmaze.push("regexfilt-level6", "/regexfilt/level6/?query=a", "regex replaces alert with _alert_, use confirm/prompt",
  vuln: "reflected-html", delivery: ["query"], note: "\"alert\" becomes \"_alert_\"; confirm/prompt are untouched")
maze_get "/regexfilt/level6/" do |env|
  query = env.params.query.fetch("query", "")
  filtered = query.gsub(/alert/i, "_alert_")

  "<html><body>#{filtered}</body></html>"
end
