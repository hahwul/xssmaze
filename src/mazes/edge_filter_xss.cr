def load_edge_filter_xss
  # Level 1: Strips 'script' keyword (case-insensitive) but allows everything else - use <img onerror>
  Xssmaze.push("edgefilter-level1", "/edgefilter/level1/?query=a", "strips script keyword but allows other tags and event handlers")
  maze_get "/edgefilter/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/script/i, "")

    "<html><head></head><body>
    <h1>Edge Filter Level 1</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 2: Strips all tags matching <[^>]+> pattern once, but double-wrapped tags survive
  # Outer angle brackets get consumed, leaving inner tag intact
  Xssmaze.push("edgefilter-level2", "/edgefilter/level2/?query=a", "single-pass tag regex strip (double-wrap bypass)")
  maze_get "/edgefilter/level2/" do |env|
    query = env.params.query["query"]
    # Single-pass strip: matches <...> greedily
    filtered = query.gsub(/<[^>]+>/, "")

    "<html><head></head><body>
    <h1>Edge Filter Level 2</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 3: Reflection in an attribute value="QUERY" - < encoded only when followed by alpha char
  # Break out of attribute with double-quote instead
  Xssmaze.push("edgefilter-level3", "/edgefilter/level3/?query=a", "angle bracket filter only before alpha chars, reflection in attribute")
  maze_get "/edgefilter/level3/" do |env|
    query = env.params.query["query"]
    # Encode < only when followed by a letter (tries to block tags but misses attribute escape)
    filtered = query.gsub(/<([a-zA-Z])/) { |_match| "&lt;#{$1}" }

    "<html><head></head><body>
    <h1>Edge Filter Level 3</h1>
    <input type=\"text\" value=\"#{filtered}\">
    </body></html>"
  end

  # Level 4: Strips event handlers (on[a-z]+=) but doesn't strip tags - use <script>alert(1)</script>
  Xssmaze.push("edgefilter-level4", "/edgefilter/level4/?query=a", "strips event handlers but allows script tags")
  maze_get "/edgefilter/level4/" do |env|
    query = env.params.query["query"]
    # Remove event handler attributes like onclick=, onerror=, onload=, etc.
    filtered = query.gsub(/on[a-zA-Z]+\s*=/i, "")

    "<html><head></head><body>
    <h1>Edge Filter Level 4</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 5: Strips < > " ' but reflected inside <script>var x=QUERY;</script> (no quotes around QUERY)
  # Inject raw JS like 1;alert(1) since no quotes to break out of and no angle brackets needed
  Xssmaze.push("edgefilter-level5", "/edgefilter/level5/?query=a", "strips angle brackets and quotes but reflects in raw JS context")
  maze_get "/edgefilter/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("<", "").gsub(">", "").gsub("\"", "").gsub("'", "")

    "<html><head></head><body>
    <h1>Edge Filter Level 5</h1>
    <script>var x=#{filtered};</script>
    </body></html>"
  end

  # Level 6: HTML encodes < > " ' & but only in first 20 chars of input, rest is raw
  Xssmaze.push("edgefilter-level6", "/edgefilter/level6/?query=a", "HTML encode first 20 chars only, rest is raw reflection")
  maze_get "/edgefilter/level6/" do |env|
    query = env.params.query["query"]
    if query.size > 20
      head = query[0, 20]
      tail = query[20..]
      encoded_head = head.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;").gsub("'", "&#39;")
      result = encoded_head + tail
    else
      result = query.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;").gsub("'", "&#39;")
    end

    "<html><head></head><body>
    <h1>Edge Filter Level 6</h1>
    <div>#{result}</div>
    </body></html>"
  end
end
