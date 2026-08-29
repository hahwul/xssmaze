Xssmaze.push("srcdoc-level1", "/srcdoc/level1/?query=a", "iframe srcdoc raw reflection",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"])
maze_get "/srcdoc/level1/" do |env|
  query = env.params.query.fetch("query", "")
  "<iframe srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level2", "/srcdoc/level2/?query=a", "srcdoc with double-quote strip (single-quote bypass)",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "double quotes stripped; use single quotes")
maze_get "/srcdoc/level2/" do |env|
  query = env.params.query.fetch("query", "").gsub("\"", "")
  "<iframe srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level3", "/srcdoc/level3/?query=a", "srcdoc HTML-encoded outside, parsed inside",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "entity-encoded in the outer document but decoded again when srcdoc is parsed")
maze_get "/srcdoc/level3/" do |env|
  query = env.params.query.fetch("query", "").gsub("\"", "&quot;")
  "<iframe srcdoc=\"<p>#{query}</p>\"></iframe>"
end

Xssmaze.push("srcdoc-level4", "/srcdoc/level4/?query=a", "srcdoc with sandbox=allow-scripts",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "sandbox='allow-scripts' still permits script execution inside the frame")
maze_get "/srcdoc/level4/" do |env|
  query = env.params.query.fetch("query", "")
  "<iframe sandbox='allow-scripts' srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level5", "/srcdoc/level5/?query=a", "srcdoc built from concat, &lt;script&gt; stripped only",
  vuln: "reflected-attr", sinks: ["srcdoc"], delivery: ["query"], note: "<script> tags stripped; use an event handler")
maze_get "/srcdoc/level5/" do |env|
  query = env.params.query.fetch("query", "").gsub(/<script[^>]*>/i, "").gsub("</script>", "")
  "<iframe srcdoc=\"&lt;html&gt;&lt;body&gt;#{query}&lt;/body&gt;&lt;/html&gt;\"></iframe>"
end
