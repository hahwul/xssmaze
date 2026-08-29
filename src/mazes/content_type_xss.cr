# Level 1: text/xml content type with raw reflection
Xssmaze.push("ctype-level1", "/ctype/level1/?query=a", "text/xml content type with raw reflection",
  vuln: "reflected-html", delivery: ["query"], note: "parsed as an XML document: the payload must stay well-formed and carry the XHTML namespace on its script element")
maze_get "/ctype/level1/" do |env|
  query = env.params.query["query"]
  env.response.content_type = "text/xml"

  "<?xml version=\"1.0\"?><root>#{query}</root>"
end

# Level 2: application/xhtml+xml content type with raw reflection
Xssmaze.push("ctype-level2", "/ctype/level2/?query=a", "application/xhtml+xml with raw reflection",
  vuln: "reflected-html", delivery: ["query"], note: "parsed as XHTML, so the payload must be well-formed XML or the document fails to render at all")
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
Xssmaze.push("ctype-level3", "/ctype/level3/?query=a", "text/html with CDATA section reflection",
  vuln: "reflected-html", delivery: ["query"], note: "the HTML parser treats <![CDATA[ as a bogus comment that ends at the first >, so lead the payload with > to escape it")
maze_get "/ctype/level3/" do |env|
  query = env.params.query["query"]
  env.response.content_type = "text/html"

  "<html><body><![CDATA[#{query}]]></body></html>"
end

# Level 4: JSONP response with callback parameter
Xssmaze.push("ctype-level4", "/ctype/level4/?callback=func", "JSONP callback with application/javascript", "GET", ["callback"],
  vuln: "reflected-js", delivery: ["query"], note: "the injectable parameter is callback, not query; served as application/javascript, so it runs in a page that loads this URL with <script src> rather than on direct navigation")
maze_get "/ctype/level4/" do |env|
  callback = env.params.query.fetch("callback", "func")
  env.response.content_type = "application/javascript"

  "#{callback}({\"data\":\"test\"})"
end

# Level 5: image/svg+xml with reflection inside SVG text element
Xssmaze.push("ctype-level5", "/ctype/level5/?query=a", "image/svg+xml with SVG text reflection",
  vuln: "reflected-html", delivery: ["query"], note: "standalone SVG document: scripts run on direct navigation but not when the URL is used as an <img> source, and the payload must be well-formed XML")
maze_get "/ctype/level5/" do |env|
  query = env.params.query["query"]
  env.response.content_type = "image/svg+xml"

  "<svg xmlns=\"http://www.w3.org/2000/svg\"><text>#{query}</text></svg>"
end

# Level 6: text/html with X-Content-Type-Options: nosniff and raw reflection
Xssmaze.push("ctype-level6", "/ctype/level6/?query=a", "text/html with nosniff and raw reflection",
  vuln: "reflected-html", delivery: ["query"], note: "the nosniff header is not a control here: the response really is text/html, so the reflection executes")
maze_get "/ctype/level6/" do |env|
  query = env.params.query["query"]
  env.response.content_type = "text/html"
  env.response.headers["X-Content-Type-Options"] = "nosniff"

  "<html><body>#{query}</body></html>"
end
