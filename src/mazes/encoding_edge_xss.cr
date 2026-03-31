def load_encoding_edge_xss
  # Level 1: Server HTML-encodes only the literal pair "<>" when they appear adjacent
  # Individual < or > pass through untouched — standard injection works
  Xssmaze.push("encodingedge-level1", "/encodingedge/level1/?query=a", "only adjacent <> pair encoded, individual < > pass through")
  maze_get "/encodingedge/level1/" do |env|
    query = env.params.query["query"]
    # Only encode the exact string "<>" — individual angle brackets survive
    filtered = query.gsub("<>", "&lt;&gt;")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 2: Server strips "<script" (case-sensitive) but not "<Script" or "<SCRIPT"
  # Mixed case like <Script>alert(1)</Script> bypasses the filter
  Xssmaze.push("encodingedge-level2", "/encodingedge/level2/?query=a", "case-sensitive <script strip (mixed case bypass)")
  maze_get "/encodingedge/level2/" do |env|
    query = env.params.query["query"]
    # Case-sensitive strip — only lowercase "<script" is removed
    filtered = query.gsub("<script", "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 3: Server replaces only the FIRST double quote with &quot; (using .sub not .gsub)
  # Reflected in attribute context — send a sacrificial " first, then the real breakout "
  Xssmaze.push("encodingedge-level3", "/encodingedge/level3/?query=a", "only first double-quote encoded (sub not gsub)")
  maze_get "/encodingedge/level3/" do |env|
    query = env.params.query["query"]
    # Only first " is escaped — second " can break out of attribute
    filtered = query.sub("\"", "&quot;")

    "<html><body><input type=\"text\" value=\"#{filtered}\"></body></html>"
  end

  # Level 4: Server hex-encodes all alphabetic characters in the first 10 characters of input
  # Characters after position 10 are left raw — pad with 10 digits then inject
  Xssmaze.push("encodingedge-level4", "/encodingedge/level4/?query=a", "first 10 chars alpha hex-encoded, rest raw")
  maze_get "/encodingedge/level4/" do |env|
    query = env.params.query["query"]
    # Hex-encode alpha chars in first 10 characters only
    prefix = query[0, Math.min(10, query.size)]
    suffix = query.size > 10 ? query[10..] : ""
    encoded_prefix = prefix.gsub(/[a-zA-Z]/) { |ch| "&#x#{ch.bytes.first.to_s(16)};" }
    filtered = encoded_prefix + suffix

    "<html><body>#{filtered}</body></html>"
  end

  # Level 5: Server converts < to fullwidth ＜ and > to fullwidth ＞
  # Reflected in attribute value — no angle brackets needed, break out with " and add event handler
  Xssmaze.push("encodingedge-level5", "/encodingedge/level5/?query=a", "angle brackets to fullwidth, reflected in attribute (quote breakout)")
  maze_get "/encodingedge/level5/" do |env|
    query = env.params.query["query"]
    # Convert angle brackets to fullwidth Unicode equivalents
    filtered = query.gsub("<", "\uFF1C").gsub(">", "\uFF1E")

    "<html><body><input type=\"text\" value=\"#{filtered}\"></body></html>"
  end

  # Level 6: Server strips everything matching /<[^>]*>/ (angle-bracket-enclosed content) from QUERY
  # Reflected in attribute value — since angles are stripped, use " to break out of attribute
  # No angle brackets needed for attribute-context XSS: " onfocus=alert(1) autofocus "
  Xssmaze.push("encodingedge-level6", "/encodingedge/level6/?query=a", "regex strips <...> tags from input, reflected in attribute (no angles needed)")
  maze_get "/encodingedge/level6/" do |env|
    query = env.params.query["query"]
    # Strip anything that looks like an HTML tag
    filtered = query.gsub(/<[^>]*>/, "")

    "<html><body><input type=\"text\" value=\"#{filtered}\"></body></html>"
  end
end
