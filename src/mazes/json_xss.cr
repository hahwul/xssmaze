Xssmaze.push("json-xss-level1", "/json/level1/?query=a", "JSON response XSS (JSONP)", "GET", ["query", "callback"],
  vuln: "reflected-js", delivery: ["query"], note: "JSONP served as application/javascript: both query (inside a JS string) and the unfiltered callback name are reflected, but the response only executes when it is loaded as a <script> — browsing to the URL renders nothing")
maze_get "/json/level1/" do |env|
  query = env.params.query.fetch("query", "")
  callback = env.params.query["callback"]? || "callback"
  env.response.content_type = "application/javascript"

  "#{callback}({\"message\": \"#{query}\", \"status\": \"success\"})"
end

Xssmaze.push("json-xss-level2", "/json/level2/?query=a", "JSON XSS with HTML entities bypass",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "the payload is reflected raw, but the response is served as application/json, which no modern browser parses as HTML, so the markup never executes; reporting no XSS here is the correct result")
maze_get "/json/level2/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.content_type = "application/json"

  "{\"html_content\": \"<div>#{query}</div>\", \"escaped\": false}"
end

Xssmaze.push("json-xss-level3", "/json/level3/?query=a", "JSON XSS with Unicode escape",
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "served as application/json, and quotes and backslashes are escaped, so the value cannot even break out of its JSON string")
maze_get "/json/level3/" do |env|
  query = env.params.query.fetch("query", "")
  env.response.content_type = "application/json"

  # Simulate improper Unicode handling
  unicode_query = query.gsub("\\", "\\\\").gsub("\"", "\\\"")
  "{\"data\": \"#{unicode_query}\", \"type\": \"unicode\"}"
end

Xssmaze.push("json-xss-level4", "/json/level4/?query=a", "JSON XSS in script tag context",
  vuln: "reflected-js", delivery: ["query"], note: "the value lands in a double-quoted JS string; that same string is later written with innerHTML, so a tag payload also fires without a breakout")
maze_get "/json/level4/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>JSON XSS Level 4</h1>
  <script>
    var jsonData = {\"userInput\": \"#{query}\"};
    document.body.innerHTML += '<div>Data: ' + jsonData.userInput + '</div>';
  </script>
  </body></html>"
end

Xssmaze.push("json-xss-level5", "/json/level5/?query=a", "JSON XSS with array injection",
  vuln: "reflected-js", delivery: ["query"], note: "the value lands in a JS array string literal that is then passed to document.write")
maze_get "/json/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>JSON XSS Level 5</h1>
  <script>
    var items = [\"#{query}\"];
    for(var i = 0; i < items.length; i++) {
      document.write('<li>' + items[i] + '</li>');
    }
  </script>
  </body></html>"
end

Xssmaze.push("json-xss-level6", "/json/level6/?query=a", "JSON XSS with nested object injection",
  vuln: "reflected-js", delivery: ["query"], note: "the value lands in a nested JS object literal string that is later written with innerHTML")
maze_get "/json/level6/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>JSON XSS Level 6</h1>
  <script>
    var config = {
      \"user\": {
        \"name\": \"#{query}\",
        \"role\": \"guest\"
      }
    };
    document.getElementById = function(id) {
      return {innerHTML: ''};
    };
    document.body.innerHTML += '<div>Welcome ' + config.user.name + '</div>';
  </script>
  </body></html>"
end
