def load_fragment_xss
  # Level 1: Reflection inside <select><option value="QUERY">
  # Bypass: close option and select tags, then inject HTML
  # e.g. "></option></select><script>alert(1)</script>
  Xssmaze.push("fragment-level1", "/fragment/level1/?query=a", "reflection in option value inside select (break out of option/select)")
  maze_get "/fragment/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><select><option value=\"#{query}\">Choose</option></select></body></html>"
  end

  # Level 2: Reflection inside <pre> tag with HTML entities for <> but only first occurrence
  # Uses .sub (not .gsub), so only the first < and > are encoded.
  # Bypass: send dummy <> first to consume the .sub, then real payload
  # e.g. <> <script>alert(1)</script>
  Xssmaze.push("fragment-level2", "/fragment/level2/?query=a", "reflection in pre tag with .sub encoding (only first <> encoded)")
  maze_get "/fragment/level2/" do |env|
    query = env.params.query["query"]
    filtered = query.sub("<", "&lt;").sub(">", "&gt;")

    "<html><body><pre>#{filtered}</pre></body></html>"
  end

  # Level 3: Reflection inside <svg> tag as text node
  # Bypass: inject SVG event handlers or close svg and inject HTML
  # e.g. </svg><script>alert(1)</script> or <svg onload=alert(1)>
  Xssmaze.push("fragment-level3", "/fragment/level3/?query=a", "reflection inside svg tag as text node")
  maze_get "/fragment/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><svg><text x=\"10\" y=\"20\">#{query}</text></svg></body></html>"
  end

  # Level 4: Reflection inside <math> tag
  # Bypass: close the math tag with </math> then inject HTML
  # e.g. </math><script>alert(1)</script>
  Xssmaze.push("fragment-level4", "/fragment/level4/?query=a", "reflection inside math tag (close tag escape)")
  maze_get "/fragment/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><math><mi>#{query}</mi></math></body></html>"
  end

  # Level 5: Reflection inside <details><summary>QUERY</summary>
  # Bypass: close summary and details tags, then inject HTML
  # e.g. </summary></details><script>alert(1)</script>
  Xssmaze.push("fragment-level5", "/fragment/level5/?query=a", "reflection inside details/summary (break out and inject)")
  maze_get "/fragment/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><details><summary>#{query}</summary><p>Details content here.</p></details></body></html>"
  end

  # Level 6: Reflection inside <marquee> tag
  # Bypass: close the marquee tag with </marquee> then inject HTML
  # e.g. </marquee><script>alert(1)</script>
  Xssmaze.push("fragment-level6", "/fragment/level6/?query=a", "reflection inside marquee tag (close tag escape)")
  maze_get "/fragment/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><marquee>#{query}</marquee></body></html>"
  end
end
