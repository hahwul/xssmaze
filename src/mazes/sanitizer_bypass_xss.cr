require "html"

# Level 1: HTML entity encode body but not attributes
Xssmaze.push("sanitizer-level1", "/sanitizer/level1/?query=a", "HTML entity body + raw attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "the body copy is HTML-escaped; the title attribute is raw, so break out with the quote")
maze_get "/sanitizer/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body><div title=\"#{query}\">#{HTML.escape(query)}</div></body></html>"
end

# Level 2: Strip script/iframe/object tags recursively
Xssmaze.push("sanitizer-level2", "/sanitizer/level2/?query=a", "recursive dangerous tag strip",
  vuln: "reflected-html", delivery: ["query"], note: "script/iframe/object keywords removed recursively; use a different tag or event vector")
maze_get "/sanitizer/level2/" do |env|
  query = Filters.strip_keyword_recursive(env.params.query.fetch("query", ""), "script")
  query = Filters.strip_keyword_recursive(query, "iframe")
  query = Filters.strip_keyword_recursive(query, "object")

  "<html><body>#{query}</body></html>"
end

# Level 3: Whitelist only p, b, i, a, br tags
Xssmaze.push("sanitizer-level3", "/sanitizer/level3/?query=a", "tag whitelist: p/b/i/a/br only",
  vuln: "reflected-html", delivery: ["query"], note: "only p/b/i/a/br are whitelisted, but <a> keeps its attributes; use an <a> event handler or javascript: href (needs interaction)")
maze_get "/sanitizer/level3/" do |env|
  query = Filters.whitelist_tags(env.params.query.fetch("query", ""), ["p", "b", "i", "a", "br"])

  "<html><body>#{query}</body></html>"
end

# Level 4: Replace <script with <!-- and </script> with -->
Xssmaze.push("sanitizer-level4", "/sanitizer/level4/?query=a", "script to comment replacement",
  vuln: "reflected-html", delivery: ["query"], note: "<script>...</script> is turned into an HTML comment; use a non-script vector like <img onerror>")
maze_get "/sanitizer/level4/" do |env|
  query = env.params.query.fetch("query", "")
  query = query.gsub(/<script/i, "<!--").gsub(/<\/script>/i, "-->")

  "<html><body>#{query}</body></html>"
end

# Level 5: Double HTML entity encode
Xssmaze.push("sanitizer-level5", "/sanitizer/level5/?query=a", "double HTML entity encode (browser decodes once)",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "double HTML-entity encoded; the browser decodes only once, leaving inert entities in both the body and the title attribute, so no breakout is possible")
maze_get "/sanitizer/level5/" do |env|
  query = env.params.query.fetch("query", "")
  # Double encode: < → &amp;lt;
  # Browser will decode once to &lt; which is still safe in body
  # But if injected in an attribute that browser decodes, it might work
  encoded = HTML.escape(HTML.escape(query))

  "<html><body><div title=\"#{encoded}\">#{encoded}</div></body></html>"
end

# Level 6: Allow href but strip javascript: and data:
Xssmaze.push("sanitizer-level6", "/sanitizer/level6/?query=a", "href allowed, javascript:/data: stripped",
  vuln: "reflected-html", delivery: ["query"], note: "only <a> is allowed and javascript:/data: hrefs are stripped, but event-handler attributes on <a> survive (needs interaction)")
maze_get "/sanitizer/level6/" do |env|
  query = Filters.whitelist_tags(env.params.query.fetch("query", ""), ["a"])
  # Additionally strip dangerous protocols from href
  query = query.gsub(/href\s*=\s*["']?\s*javascript\s*:/i, "href=\"#")
  query = query.gsub(/href\s*=\s*["']?\s*data\s*:/i, "href=\"#")

  "<html><body>#{query}</body></html>"
end
