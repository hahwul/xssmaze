def load_multiple_output_xss
  # Level 1: Query in <div> (raw) and <span> (HTML encoded)
  # The div is exploitable; the span is safe
  Xssmaze.push("multipleoutput-level1", "/multipleoutput/level1/?query=a", "raw div + encoded span")
  maze_get "/multipleoutput/level1/" do |env|
    query = env.params.query["query"]
    encoded = HTML.escape(query)

    "<html><body><div>#{query}</div><span>#{encoded}</span></body></html>"
  end

  # Level 2: Query in <script> (JS escaped) and <p> (raw)
  # The p tag is exploitable; the script context is escaped
  Xssmaze.push("multipleoutput-level2", "/multipleoutput/level2/?query=a", "JS-escaped script var + raw p tag")
  maze_get "/multipleoutput/level2/" do |env|
    query = env.params.query["query"]
    js_escaped = query.gsub("\\", "\\\\").gsub("'", "\\'").gsub("\"", "\\\"").gsub("<", "\\x3c").gsub(">", "\\x3e")

    "<html><body><script>var a=\"#{js_escaped}\";</script><p>#{query}</p></body></html>"
  end

  # Level 3: Query in <input> (HTML encoded) and in HTML comment (raw)
  # Break out of the comment with -->
  Xssmaze.push("multipleoutput-level3", "/multipleoutput/level3/?query=a", "encoded attribute + raw HTML comment")
  maze_get "/multipleoutput/level3/" do |env|
    query = env.params.query["query"]
    encoded = HTML.escape(query)

    "<html><body><input value=\"#{encoded}\"><!-- #{query} --></body></html>"
  end

  # Level 4: Three outputs — encoded in attribute, encoded in title, raw in div
  # The div is exploitable
  Xssmaze.push("multipleoutput-level4", "/multipleoutput/level4/?query=a", "triple output: encoded attr + encoded title + raw div")
  maze_get "/multipleoutput/level4/" do |env|
    query = env.params.query["query"]
    encoded = HTML.escape(query)

    "<html><head><title>#{encoded}</title></head><body><input value=\"#{encoded}\"><div>#{query}</div></body></html>"
  end

  # Level 5: Query in <style> (with <> encoded) and <p> (raw)
  # The p tag is exploitable; the style context encodes angle brackets
  Xssmaze.push("multipleoutput-level5", "/multipleoutput/level5/?query=a", "encoded style comment + raw p tag")
  maze_get "/multipleoutput/level5/" do |env|
    query = env.params.query["query"]
    style_safe = query.gsub("<", "&lt;").gsub(">", "&gt;")

    "<html><head><style>/* #{style_safe} */</style></head><body><p>#{query}</p></body></html>"
  end

  # Level 6: Four outputs — 3 encoded in various contexts, 1 raw in footer
  # The footer is exploitable
  Xssmaze.push("multipleoutput-level6", "/multipleoutput/level6/?query=a", "four outputs: 3 encoded + 1 raw footer")
  maze_get "/multipleoutput/level6/" do |env|
    query = env.params.query["query"]
    encoded = HTML.escape(query)

    "<html><head><title>#{encoded}</title></head><body><input value=\"#{encoded}\"><div>#{encoded}</div><footer>#{query}</footer></body></html>"
  end
end
