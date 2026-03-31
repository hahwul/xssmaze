require "html"

def load_sanitizer_bypass_xss
  # Level 1: HTML entity encode body but not attributes
  Xssmaze.push("sanitizer-level1", "/sanitizer/level1/?query=a", "HTML entity body + raw attribute")
  maze_get "/sanitizer/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div title=\"#{query}\">#{HTML.escape(query)}</div></body></html>"
  end

  # Level 2: Strip script/iframe/object tags recursively
  Xssmaze.push("sanitizer-level2", "/sanitizer/level2/?query=a", "recursive dangerous tag strip")
  maze_get "/sanitizer/level2/" do |env|
    query = Filters.strip_keyword_recursive(env.params.query["query"], "script")
    query = Filters.strip_keyword_recursive(query, "iframe")
    query = Filters.strip_keyword_recursive(query, "object")

    "<html><body>#{query}</body></html>"
  end

  # Level 3: Whitelist only p, b, i, a, br tags
  Xssmaze.push("sanitizer-level3", "/sanitizer/level3/?query=a", "tag whitelist: p/b/i/a/br only")
  maze_get "/sanitizer/level3/" do |env|
    query = Filters.whitelist_tags(env.params.query["query"], ["p", "b", "i", "a", "br"])

    "<html><body>#{query}</body></html>"
  end

  # Level 4: Replace <script with <!-- and </script> with -->
  Xssmaze.push("sanitizer-level4", "/sanitizer/level4/?query=a", "script to comment replacement")
  maze_get "/sanitizer/level4/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/<script/i, "<!--").gsub(/<\/script>/i, "-->")

    "<html><body>#{query}</body></html>"
  end

  # Level 5: Double HTML entity encode
  Xssmaze.push("sanitizer-level5", "/sanitizer/level5/?query=a", "double HTML entity encode (browser decodes once)")
  maze_get "/sanitizer/level5/" do |env|
    query = env.params.query["query"]
    # Double encode: < → &amp;lt;
    # Browser will decode once to &lt; which is still safe in body
    # But if injected in an attribute that browser decodes, it might work
    encoded = HTML.escape(HTML.escape(query))

    "<html><body><div title=\"#{encoded}\">#{encoded}</div></body></html>"
  end

  # Level 6: Allow href but strip javascript: and data:
  Xssmaze.push("sanitizer-level6", "/sanitizer/level6/?query=a", "href allowed, javascript:/data: stripped")
  maze_get "/sanitizer/level6/" do |env|
    query = Filters.whitelist_tags(env.params.query["query"], ["a"])
    # Additionally strip dangerous protocols from href
    query = query.gsub(/href\s*=\s*["']?\s*javascript\s*:/i, "href=\"#")
    query = query.gsub(/href\s*=\s*["']?\s*data\s*:/i, "href=\"#")

    "<html><body>#{query}</body></html>"
  end
end
