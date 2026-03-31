def load_json_context_xss
  # Level 1: Response is Content-Type: text/html with JSON body
  # HTML injection works since the browser renders it as HTML
  Xssmaze.push("jsonctx-level1", "/jsonctx/level1/?query=a", "JSON body with text/html content type, HTML injection")
  maze_get "/jsonctx/level1/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "{\"result\":\"#{query}\"}"
  end

  # Level 2: JSON embedded in a <script> block with var assignment
  # Close the script tag and inject HTML
  Xssmaze.push("jsonctx-level2", "/jsonctx/level2/?query=a", "JSON in script block, close script to inject")
  maze_get "/jsonctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var data={\"q\":\"#{query}\"};</script></body></html>"
  end

  # Level 3: JSONP callback with query reflected in data, Content-Type text/html
  # Inject HTML since browser renders as HTML
  Xssmaze.push("jsonctx-level3", "/jsonctx/level3/?query=a", "JSONP response with text/html, HTML injection in data")
  maze_get "/jsonctx/level3/" do |env|
    query = env.params.query["query"]
    callback = env.params.query.fetch("callback", "callback")
    env.response.content_type = "text/html"

    "#{callback}({\"data\":\"#{query}\"})"
  end

  # Level 4: JSON array in a <script> block
  # Close script tag and inject
  Xssmaze.push("jsonctx-level4", "/jsonctx/level4/?query=a", "JSON array in script block, close script to inject")
  maze_get "/jsonctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var items=[\"#{query}\"];</script></body></html>"
  end

  # Level 5: Nested JSON in a <script> block
  # Close script tag and inject
  Xssmaze.push("jsonctx-level5", "/jsonctx/level5/?query=a", "nested JSON in script block, close script to inject")
  maze_get "/jsonctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var cfg={\"user\":{\"name\":\"#{query}\"}};</script></body></html>"
  end

  # Level 6: JSON with HTML content type, query reflected in multiple fields
  # HTML injection via either field
  Xssmaze.push("jsonctx-level6", "/jsonctx/level6/?query=a", "JSON with text/html, query in multiple fields")
  maze_get "/jsonctx/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "{\"title\":\"#{query}\",\"desc\":\"#{query}\"}"
  end
end
