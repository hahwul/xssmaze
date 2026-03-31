def load_nested_filter_xss
  # Level 1: First strips <script>, then strips <img> -- use <svg onload=alert(1)> which survives both
  Xssmaze.push("nestedfilter-level1", "/nestedfilter/level1/?query=a", "strips script then img tags (svg survives)")
  maze_get "/nestedfilter/level1/" do |env|
    query = env.params.query["query"]
    query = Filters.strip_tags(query, ["script"])
    query = Filters.strip_tags(query, ["img"])

    "<html><body>#{query}</body></html>"
  end

  # Level 2: First lowercases input, then strips <script> -- use <img src=x onerror=alert(1)>
  Xssmaze.push("nestedfilter-level2", "/nestedfilter/level2/?query=a", "lowercase then strip script (img survives)")
  maze_get "/nestedfilter/level2/" do |env|
    query = env.params.query["query"].downcase
    query = Filters.strip_tags(query, ["script"])

    "<html><body>#{query}</body></html>"
  end

  # Level 3: First strips on[a-z]+=, then strips <script> tag
  # Use <scr<script>ipt>alert(1)</scr</script>ipt> -- after <script> strip becomes <script>alert(1)</script>
  Xssmaze.push("nestedfilter-level3", "/nestedfilter/level3/?query=a", "strips event handlers then script (nested tag reconstruction)")
  maze_get "/nestedfilter/level3/" do |env|
    query = env.params.query["query"]
    query = query.gsub(/on[a-z]+=/, "")
    query = Filters.strip_tags(query, ["script"])

    "<html><body>#{query}</body></html>"
  end

  # Level 4: Strips < then strips > -- both angle brackets gone
  # Reflection in attribute context: <input value="QUERY"> -- break out with " onmouseover=alert(1) x="
  Xssmaze.push("nestedfilter-level4", "/nestedfilter/level4/?query=a", "strips < and > (attribute breakout)")
  maze_get "/nestedfilter/level4/" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "")
    query = query.gsub(">", "")

    "<html><body><input type=\"text\" value=\"#{query}\" name=\"search\"></body></html>"
  end

  # Level 5: URL-decodes once then strips <script> -- use <img src=x onerror=alert(1)> (not affected by script strip)
  Xssmaze.push("nestedfilter-level5", "/nestedfilter/level5/?query=a", "URL decode then strip script (img survives)")
  maze_get "/nestedfilter/level5/" do |env|
    query = env.params.query["query"]
    begin
      query = URI.decode(query)
    rescue
    end
    query = Filters.strip_tags(query, ["script"])

    "<html><body>#{query}</body></html>"
  end

  # Level 6: Strips "alert", then strips <script> -- use <img src=x onerror=confirm(1)>
  Xssmaze.push("nestedfilter-level6", "/nestedfilter/level6/?query=a", "strips alert keyword then script tag (confirm survives)")
  maze_get "/nestedfilter/level6/" do |env|
    query = env.params.query["query"]
    query = query.gsub("alert", "")
    query = Filters.strip_tags(query, ["script"])

    "<html><body>#{query}</body></html>"
  end
end
