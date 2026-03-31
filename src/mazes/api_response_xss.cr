def load_api_response_xss
  # Level 1: JSON-like response served as text/html
  # The query is reflected inside a JSON string value, but since Content-Type is text/html,
  # the browser will parse HTML tags embedded in the JSON.
  # Bypass: break out of JSON string with ", inject HTML like <img src=x onerror=alert(1)>
  Xssmaze.push("api-response-level1", "/api-response/level1/?query=a", "JSON-like response with text/html content type")
  maze_get "/api-response/level1/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "{\"message\":\"#{query}\",\"status\":\"ok\"}"
  end

  # Level 2: XML response served as text/html
  # The query is reflected inside an XML element, but Content-Type is text/html so
  # the browser renders HTML tags within the XML structure.
  # Bypass: inject <script>alert(1)</script> or <img src=x onerror=alert(1)>
  Xssmaze.push("api-response-level2", "/api-response/level2/?query=a", "XML response with text/html content type")
  maze_get "/api-response/level2/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "<response><message>#{query}</message></response>"
  end

  # Level 3: CSV-like response served as text/html
  # The query is reflected in a CSV-formatted body, but Content-Type is text/html,
  # so the browser treats the entire body as HTML.
  # Bypass: inject <script>alert(1)</script> directly
  Xssmaze.push("api-response-level3", "/api-response/level3/?query=a", "CSV-like response with text/html content type")
  maze_get "/api-response/level3/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "name,value\nresult,#{query}"
  end

  # Level 4: JSONP callback response served as text/html
  # The query is reflected inside JSONP data, but since Content-Type is text/html
  # the browser will parse any HTML injected into the data string.
  # Bypass: break out of JS string with ", inject </script><img src=x onerror=alert(1)>
  Xssmaze.push("api-response-level4", "/api-response/level4/?query=a", "JSONP callback response with text/html content type")
  maze_get "/api-response/level4/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "jsonpCallback({\"data\":\"#{query}\"})"
  end

  # Level 5: HTML fragment response (no doctype/html/body tags)
  # The query is reflected inside a bare HTML fragment with no wrapping document structure.
  # Bypass: inject <script>alert(1)</script> or event handlers to break out of div
  Xssmaze.push("api-response-level5", "/api-response/level5/?query=a", "HTML fragment response without full document structure")
  maze_get "/api-response/level5/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "<div class=\"result\">#{query}</div>"
  end

  # Level 6: Plain text error message served as text/html
  # A simple error string with the query reflected, but Content-Type is text/html
  # so the browser will render HTML tags embedded in the error text.
  # Bypass: inject <script>alert(1)</script> directly
  Xssmaze.push("api-response-level6", "/api-response/level6/?query=a", "Plain text error response with text/html content type")
  maze_get "/api-response/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "Error: #{query}"
  end
end
