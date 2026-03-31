def load_recursive_filter_xss
  # Level 1: Strip <script non-recursively (single pass)
  Xssmaze.push("recfilt-level1", "/recfilt/level1/?query=a", "strip <script non-recursively (single pass)")
  maze_get "/recfilt/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/<script/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 2: Strip on* event handlers non-recursively
  Xssmaze.push("recfilt-level2", "/recfilt/level2/?query=a", "strip on* event handlers non-recursively")
  maze_get "/recfilt/level2/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/\bon\w+\s*=/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 3: Replace < with empty but only first occurrence
  Xssmaze.push("recfilt-level3", "/recfilt/level3/?query=a", "replace first < only")
  maze_get "/recfilt/level3/" do |env|
    query = env.params.query["query"]
    filtered = query.sub("<", "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 4: Strip javascript: protocol non-recursively, reflect in href
  Xssmaze.push("recfilt-level4", "/recfilt/level4/?query=a", "strip javascript: non-recursively in href context")
  maze_get "/recfilt/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/javascript:/i, "")

    "<html><body><a href=\"#{filtered}\">link</a></body></html>"
  end

  # Level 5: Double-escape quotes but reflect in JS string (exploitable via </script>)
  Xssmaze.push("recfilt-level5", "/recfilt/level5/?query=a", "double-escape quotes in JS string context")
  maze_get "/recfilt/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("\"", "\\\"")

    "<html><body>
    <script>var x = \"#{filtered}\";</script>
    </body></html>"
  end

  # Level 6: Strip parentheses non-recursively (bypass with backtick templates)
  Xssmaze.push("recfilt-level6", "/recfilt/level6/?query=a", "strip parentheses non-recursively")
  maze_get "/recfilt/level6/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/[()]/, "")

    "<html><body>#{filtered}</body></html>"
  end
end
