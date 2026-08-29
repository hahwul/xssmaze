Xssmaze.push("attrname-level1", "/attrname/level1/?query=a", "user controls attribute name on a tag",
  vuln: "reflected-attr", delivery: ["query"], note: "the value lands in attribute-name position, so no quote breakout is needed: onmouseover=alert(1) x works as-is")
maze_get "/attrname/level1/" do |env|
  query = env.params.query.fetch("query", "")
  "<div #{query}='value'>hi</div>"
end

Xssmaze.push("attrname-level2", "/attrname/level2/?query=a", "attribute name on a button (onclick injection)",
  vuln: "reflected-attr", delivery: ["query"], note: "the attribute value is fixed to alert(1); supply only the name, e.g. autofocus onfocus, so it fires without a click")
maze_get "/attrname/level2/" do |env|
  query = env.params.query.fetch("query", "")
  "<button #{query}='alert(1)'>click</button>"
end

Xssmaze.push("attrname-level3", "/attrname/level3/?query=a", "attribute name with space stripped (newline bypass)",
  vuln: "reflected-attr", delivery: ["query"], note: "literal spaces are stripped, so separate attributes with a tab or newline; the trailing =go value is not callable, so bring your own handler")
maze_get "/attrname/level3/" do |env|
  query = env.params.query.fetch("query", "").gsub(" ", "")
  "<input type='text' #{query}='go'>"
end

Xssmaze.push("attrname-level4", "/attrname/level4/?query=a", "attribute name on <a>, equals stripped (boolean attr bypass)",
  vuln: "reflected-attr", delivery: ["query"], note: "= is stripped, so no attribute can be given a value; close the tag and inject <script>alert(1)</script>, which needs no =")
maze_get "/attrname/level4/" do |env|
  query = env.params.query.fetch("query", "").gsub("=", "")
  "<a href='#' #{query}>link</a>"
end
