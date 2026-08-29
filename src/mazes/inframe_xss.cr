Xssmaze.push("inframe-xss-level1", "/inframe/level1/?url=a", "src attribute in iframe tag", "GET", ["url"],
  vuln: "reflected-attr", sinks: ["iframe.src"], delivery: ["query"], note: "the parameter is url, not query; both a quote breakout and a javascript: URL work")
maze_get "/inframe/level1/" do |env|
  query = env.params.query["url"]

  "<iframe src='#{query}'></iframe>"
end

Xssmaze.push("inframe-xss-level2", "/inframe/level2/?url=a", "src attribute in iframe tag", "GET", ["url"],
  vuln: "reflected-attr", sinks: ["iframe.src"], delivery: ["query"], note: "the parameter is url, not query; quotes are stripped so the attribute cannot be broken out, leaving a javascript: URL in the frame src")
maze_get "/inframe/level2/" do |env|
  query = env.params.query["url"]

  "<iframe src='#{query.gsub("'", "").gsub("\"", "")}'></iframe>"
end

Xssmaze.push("inframe-xss-level3", "/inframe/level3/?url=a", "src attribute in iframe tag", "GET", ["url"],
  vuln: "reflected-attr", sinks: ["iframe.src"], delivery: ["query"], note: "the parameter is url, not query; the value is lowercased and javascript: removed in one pass, so nest it as javajavascript:script:")
maze_get "/inframe/level3/" do |env|
  query = env.params.query["url"]

  "<iframe src='#{query.gsub("'", "").gsub("\"", "").downcase.gsub("javascript:", "")}'></iframe>"
end

Xssmaze.push("inframe-xss-level4", "/inframe/level4/?url=a", "src attribute in iframe tag", "GET", ["url"],
  vuln: "reflected-attr", sinks: ["iframe.src"], delivery: ["query"], note: "the parameter is url, not query; javascript: and alert are each removed in one pass, so nest both: javajavascript:script:alalertert`1`")
maze_get "/inframe/level4/" do |env|
  query = env.params.query["url"]

  "<iframe src='#{query.gsub("'", "").gsub("\"", "").downcase.gsub("javascript:", "").gsub("alert", "")}'></iframe>"
end
