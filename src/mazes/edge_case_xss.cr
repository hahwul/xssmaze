# Level 1: Null byte injection (%00 before filter check)
Xssmaze.push("edge-level1", "/edge/level1/?query=a", "null byte before filter",
  vuln: "reflected-html", delivery: ["query"], note: "the angle-bracket check only inspects the bytes before the first NUL, so a %00 prefix carries the payload past it unfiltered")
maze_get "/edge/level1/" do |env|
  query = env.params.query["query"]
  # Strip everything after null byte for filter, but reflect original
  check = query.split('\0').first || query
  if check.includes?("<") || check.includes?(">")
    "<html><body>Blocked</body></html>"
  else
    "<html><body>#{query}</body></html>"
  end
end

# Level 2: Path traversal style /../ removal, but XSS in path
Xssmaze.push("edge-level2", "/edge/level2/test", "path segment reflection", "GET", [":path"],
  vuln: "reflected-html", delivery: ["path"], note: "the payload is the URL path segment, not a query parameter")
maze_get "/edge/level2/:segment" do |env|
  seg = env.params.url["segment"]

  "<html><body><h1>Page: #{seg}</h1></body></html>"
end

# Level 3: Reflection in JSON-in-HTML (inside <script type="application/json">)
Xssmaze.push("edge-level3", "/edge/level3/?query=a", "JSON island in script tag",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "the value is placed in a <script type=application/json> island with its double quotes escaped, then JSON.parse'd and written with innerHTML — a tag payload reaches the sink with no breakout")
maze_get "/edge/level3/" do |env|
  query = env.params.query["query"]
  escaped = query.gsub("\"", "\\\"")

  "<html><body>
  <script type=\"application/json\" id=\"config\">
  {\"search\": \"#{escaped}\"}
  </script>
  <script>
  var c = JSON.parse(document.getElementById('config').textContent);
  document.body.innerHTML += '<div>' + c.search + '</div>';
  </script>
  </body></html>"
end

# Level 4: Reflection with HTML entity encoded output but in dangerous context
# Server encodes <> to entities, but reflects in onclick - browser decodes entities in attribute
Xssmaze.push("edge-level4", "/edge/level4/?query=a", "HTML entity in event handler attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are entity-encoded, but the value sits in a single-quoted JS string inside an onclick handler; the handler only runs on click, so break out of the double-quoted attribute to inject a self-firing tag")
maze_get "/edge/level4/" do |env|
  query = Filters.encode_angles(env.params.query["query"])

  "<html><body><div onclick=\"handle('#{query}')\">Click</div></body></html>"
end

# Level 5: Multiline reflection (payload split across lines)
Xssmaze.push("edge-level5", "/edge/level5/?q1=a&q2=b", "split payload across two params", "GET", ["q1", "q2"],
  vuln: "reflected-attr", delivery: ["query"], note: "the payload is split across two parameters concatenated into one title attribute")
maze_get "/edge/level5/" do |env|
  q1 = env.params.query.fetch("q1", "a")
  q2 = env.params.query.fetch("q2", "b")

  "<html><body><div title=\"#{q1}#{q2}\">Content</div></body></html>"
end

# Level 6: Reflection in SVG attribute
Xssmaze.push("edge-level6", "/edge/level6/?query=a", "SVG fill attribute injection",
  vuln: "reflected-attr", delivery: ["query"], note: "reflected into an SVG <rect fill>; inside <svg> an injected <script> is an SVG script element and still runs")
maze_get "/edge/level6/" do |env|
  query = env.params.query["query"]

  "<html><body><svg><rect fill=\"#{query}\" width=\"100\" height=\"100\"/></svg></body></html>"
end

# Level 7: Triple parameter concatenation in JS
Xssmaze.push("edge-level7", "/edge/level7/?a=x&b=y&c=z", "triple param concat in JS string", "GET", ["a", "b", "c"],
  vuln: "reflected-js", delivery: ["query"], note: "three parameters are concatenated into one single-quoted JS string")
maze_get "/edge/level7/" do |env|
  a = env.params.query.fetch("a", "x")
  b = env.params.query.fetch("b", "y")
  c = env.params.query.fetch("c", "z")

  "<script>var data = '#{a}/#{b}/#{c}';</script>"
end

# Level 8: Reflection in textarea with </textarea> not stripped
Xssmaze.push("edge-level8", "/edge/level8/?query=a", "textarea body (close tag allowed)",
  vuln: "reflected-html", delivery: ["query"], note: "reflected into <textarea> RCDATA; close </textarea> first")
maze_get "/edge/level8/" do |env|
  query = env.params.query["query"]

  "<html><body><textarea>#{query}</textarea></body></html>"
end
