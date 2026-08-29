Xssmaze.push("injs-xss-level1", "/injs/level1/?query=a", "injs-xss",
  vuln: "reflected-js", delivery: ["query"], note: "unquoted JS expression context, so a bare statement runs")
maze_get "/injs/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<script>
      var data = #{query};
  </script>"
end

Xssmaze.push("injs-xss-level2", "/injs/level2/?query=a", "injs-xss - in single quote",
  vuln: "reflected-js", delivery: ["query"])
maze_get "/injs/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<script>
      var data = '#{query}';
  </script>"
end

Xssmaze.push("injs-xss-level3", "/injs/level3/?query=a", "injs-xss - in double quote",
  vuln: "reflected-js", delivery: ["query"])
maze_get "/injs/level3/" do |env|
  query = env.params.query.fetch("query", "")

  "<script>
      var data = \"#{query}\";
  </script>"
end

Xssmaze.push("injs-xss-level4", "/injs/level4/?query=a", "injs-xss - in single quote and double quote",
  vuln: "reflected-js", delivery: ["query"], note: "single quotes are stripped, so close the <script> block instead of the string")
maze_get "/injs/level4/" do |env|
  query = env.params.query.fetch("query", "").gsub("'", "")

  "<script>
      var data = '#{query}' // this is '#{query}';
  </script>"
end

Xssmaze.push("injs-xss-level5", "/injs/level5/?query=a", "injs-xss - in comments style 1",
  vuln: "reflected-js", delivery: ["query"], note: "inside a block comment; close it with */ first")
maze_get "/injs/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<script>
      /* this is '#{query}' */
  </script>"
end

Xssmaze.push("injs-xss-level6", "/injs/level6/?query=a", "injs-xss - in comments style 2",
  vuln: "reflected-js", delivery: ["query"], note: "inside a line comment; a newline (%0a) ends it")
maze_get "/injs/level6/" do |env|
  query = env.params.query.fetch("query", "")

  "<script>
      // this is '#{query}'
  </script>"
end
