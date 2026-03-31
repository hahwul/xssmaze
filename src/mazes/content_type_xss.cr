def load_content_type_xss
  # Level 1: text/xml content type with raw reflection
  Xssmaze.push("ctype-level1", "/ctype/level1/?query=a", "text/xml content type with raw reflection")
  maze_get "/ctype/level1/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/xml"

    "<?xml version=\"1.0\"?><root>#{query}</root>"
  end

  # Level 2: application/xhtml+xml content type with raw reflection
  Xssmaze.push("ctype-level2", "/ctype/level2/?query=a", "application/xhtml+xml with raw reflection")
  maze_get "/ctype/level2/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "application/xhtml+xml"

    "<?xml version=\"1.0\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<body>#{query}</body>
</html>"
  end

  # Level 3: text/html with reflection inside XML CDATA section
  Xssmaze.push("ctype-level3", "/ctype/level3/?query=a", "text/html with CDATA section reflection")
  maze_get "/ctype/level3/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "<html><body><![CDATA[#{query}]]></body></html>"
  end

  # Level 4: JSONP response with callback parameter
  Xssmaze.push("ctype-level4", "/ctype/level4/?callback=func", "JSONP callback with application/javascript")
  maze_get "/ctype/level4/" do |env|
    callback = env.params.query.fetch("callback", "func")
    env.response.content_type = "application/javascript"

    "#{callback}({\"data\":\"test\"})"
  end

  # Level 5: image/svg+xml with reflection inside SVG text element
  Xssmaze.push("ctype-level5", "/ctype/level5/?query=a", "image/svg+xml with SVG text reflection")
  maze_get "/ctype/level5/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "image/svg+xml"

    "<svg xmlns=\"http://www.w3.org/2000/svg\"><text>#{query}</text></svg>"
  end

  # Level 6: text/html with X-Content-Type-Options: nosniff and raw reflection
  Xssmaze.push("ctype-level6", "/ctype/level6/?query=a", "text/html with nosniff and raw reflection")
  maze_get "/ctype/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["X-Content-Type-Options"] = "nosniff"

    "<html><body>#{query}</body></html>"
  end
end
