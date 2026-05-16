Xssmaze.push("srcdoc-level1", "/srcdoc/level1/?query=a", "iframe srcdoc raw reflection")
maze_get "/srcdoc/level1/" do |env|
  query = env.params.query["query"]
  "<iframe srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level2", "/srcdoc/level2/?query=a", "srcdoc with double-quote strip (single-quote bypass)")
maze_get "/srcdoc/level2/" do |env|
  query = env.params.query["query"].gsub("\"", "")
  "<iframe srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level3", "/srcdoc/level3/?query=a", "srcdoc HTML-encoded outside, parsed inside")
maze_get "/srcdoc/level3/" do |env|
  query = env.params.query["query"].gsub("\"", "&quot;")
  "<iframe srcdoc=\"<p>#{query}</p>\"></iframe>"
end

Xssmaze.push("srcdoc-level4", "/srcdoc/level4/?query=a", "srcdoc with sandbox=allow-scripts")
maze_get "/srcdoc/level4/" do |env|
  query = env.params.query["query"]
  "<iframe sandbox='allow-scripts' srcdoc=\"#{query}\"></iframe>"
end

Xssmaze.push("srcdoc-level5", "/srcdoc/level5/?query=a", "srcdoc built from concat, &lt;script&gt; stripped only")
maze_get "/srcdoc/level5/" do |env|
  query = env.params.query["query"].gsub(/<script[^>]*>/i, "").gsub("</script>", "")
  "<iframe srcdoc=\"&lt;html&gt;&lt;body&gt;#{query}&lt;/body&gt;&lt;/html&gt;\"></iframe>"
end
