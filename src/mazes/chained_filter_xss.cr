def load_chained_filter_xss
  # Level 1: Strip "script" keyword, but <> are NOT stripped so other tags work
  Xssmaze.push("chain-level1", "/chain/level1/?query=a", "strip script keyword only (other tags survive)")
  maze_get "/chain/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/script/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 2: Lowercase input + strip <script (other tags like <img survive)
  Xssmaze.push("chain-level2", "/chain/level2/?query=a", "lowercase + strip <script (other tags survive)")
  maze_get "/chain/level2/" do |env|
    query = env.params.query["query"]
    filtered = query.downcase.gsub("<script", "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 3: Replace alert with blocked (use confirm/prompt instead)
  Xssmaze.push("chain-level3", "/chain/level3/?query=a", "replace alert with blocked (confirm/prompt bypass)")
  maze_get "/chain/level3/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/alert/i, "blocked")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 4: Case-sensitive tag strip <[a-z]+ only (uppercase tags bypass)
  Xssmaze.push("chain-level4", "/chain/level4/?query=a", "case-sensitive lowercase tag strip (uppercase tags bypass)")
  maze_get "/chain/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/<[a-z]+/, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 5: Replace = with &#61; HTML entity (browser decodes in event handlers)
  Xssmaze.push("chain-level5", "/chain/level5/?query=a", "replace = with HTML entity &#61; (browser decodes in handlers)")
  maze_get "/chain/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("=", "&#61;")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 6: Strip // and /* JS comments, reflect in JS string (close script tag to bypass)
  Xssmaze.push("chain-level6", "/chain/level6/?query=a", "strip JS comments in script string context (close tag bypass)")
  maze_get "/chain/level6/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("//", "").gsub("/*", "")

    "<html><body>
    <script>var x = \"#{filtered}\";</script>
    </body></html>"
  end
end
