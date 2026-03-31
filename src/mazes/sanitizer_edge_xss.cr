require "html"

def load_sanitizer_edge_xss
  # Level 1: Strips all tags but reflects in input value attribute — attribute breakout with "
  Xssmaze.push("sanitizer-edge-level1", "/sanitizer-edge/level1/?query=a", "strip tags, reflect in input value (attribute breakout)")
  maze_get "/sanitizer-edge/level1/" do |env|
    query = env.params.query["query"]
    # Strip all HTML tags but don't escape quotes
    sanitized = query.gsub(/<[^>]*>/, "")

    "<html><body><form><input type=\"text\" name=\"search\" value=\"#{sanitized}\"></form></body></html>"
  end

  # Level 2: HTML-encodes <>"' but reflects inside script without quotes — raw JS injection
  Xssmaze.push("sanitizer-edge-level2", "/sanitizer-edge/level2/?query=a", "HTML-encode special chars, reflect in unquoted script var")
  maze_get "/sanitizer-edge/level2/" do |env|
    query = env.params.query["query"]
    # Encode HTML special chars: < > " '
    sanitized = query.gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;").gsub("'", "&#39;")

    "<html><body><script>var x=#{sanitized};</script><div id=\"out\"></div></body></html>"
  end

  # Level 3: Strips <script> recursively but allows other tags — use img/svg onerror
  Xssmaze.push("sanitizer-edge-level3", "/sanitizer-edge/level3/?query=a", "recursive script strip, other tags allowed")
  maze_get "/sanitizer-edge/level3/" do |env|
    query = env.params.query["query"]
    # Recursively strip <script> and </script> tags
    result = query
    loop do
      replaced = result.gsub(/<\/?script[^>]*>/i, "")
      break if replaced == result
      result = replaced
    end

    "<html><body>#{result}</body></html>"
  end

  # Level 4: Tag whitelist (b/i/u/em/strong) — but attributes on whitelisted tags not checked
  Xssmaze.push("sanitizer-edge-level4", "/sanitizer-edge/level4/?query=a", "tag whitelist but event attributes allowed on whitelisted tags")
  maze_get "/sanitizer-edge/level4/" do |env|
    query = env.params.query["query"]
    # Whitelist: only allow b, i, u, em, strong tags (case-sensitive check)
    # Bug: checks tag name but does NOT strip attributes on whitelisted tags
    allowed = ["b", "i", "u", "em", "strong"]
    pattern = allowed.map { |tag| Regex.escape(tag) }.join("|")
    sanitized = query.gsub(/<\/?(?!(?:#{pattern})\b)[a-z][a-z0-9]*[^>]*>/i, "")

    "<html><body>#{sanitized}</body></html>"
  end

  # Level 5: Strips tags/dangerous attrs but allows style — attribute breakout from style
  Xssmaze.push("sanitizer-edge-level5", "/sanitizer-edge/level5/?query=a", "style attribute allowed, breakout from style value")
  maze_get "/sanitizer-edge/level5/" do |env|
    query = env.params.query["query"]
    # Strip all HTML tags from query
    sanitized = query.gsub(/<[^>]*>/, "")

    "<html><body><div style=\"color: #{sanitized}\">Styled text</div></body></html>"
  end

  # Level 6: Strips javascript:/vbscript:/data: from href — attribute breakout instead
  Xssmaze.push("sanitizer-edge-level6", "/sanitizer-edge/level6/?query=a", "protocol strip in href, attribute breakout")
  maze_get "/sanitizer-edge/level6/" do |env|
    query = env.params.query["query"]
    # Strip dangerous protocols
    sanitized = query.gsub(/javascript\s*:/i, "").gsub(/vbscript\s*:/i, "").gsub(/data\s*:/i, "")

    "<html><body><a href=\"#{sanitized}\">Click here</a></body></html>"
  end
end
