Xssmaze.push("dataurl-level1", "/dataurl/level1/?query=a", "anchor href with data:text/html under user control (executes on click)",
  vuln: "reflected-attr", delivery: ["query"], note: "single-quoted anchor href holding a data:text/html URL; on click the browser renders the reflected bytes as their own HTML document")
maze_get "/dataurl/level1/" do |env|
  query = env.params.query["query"]
  "<a href='data:text/html,#{query}'>open</a>"
end

Xssmaze.push("dataurl-level2", "/dataurl/level2/?query=a", "iframe src=data:text/html with reflected body",
  vuln: "reflected-attr", delivery: ["query"], note: "iframe src=data:text/html; the reflected bytes render as the iframe own HTML document on load")
maze_get "/dataurl/level2/" do |env|
  query = env.params.query["query"]
  "<iframe src='data:text/html;charset=utf-8,#{query}'></iframe>"
end

Xssmaze.push("dataurl-level3", "/dataurl/level3/?query=a", "object data=data:text/html with reflected payload",
  vuln: "reflected-attr", delivery: ["query"], note: "object data=data:text/html; the reflected bytes render as the object document")
maze_get "/dataurl/level3/" do |env|
  query = env.params.query["query"]
  "<object data='data:text/html,#{query}'></object>"
end

Xssmaze.push("dataurl-level4", "/dataurl/level4/?query=a", "embed src=data:text/html with reflected payload",
  vuln: "reflected-attr", delivery: ["query"], note: "embed src=data:text/html; the reflected bytes render as the embedded document")
maze_get "/dataurl/level4/" do |env|
  query = env.params.query["query"]
  "<embed src='data:text/html,#{query}'>"
end
