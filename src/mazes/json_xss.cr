def load_json_xss
  Xssmaze.push("json-xss-level1", "/json/level1/?query=a", "JSON response XSS (JSONP)", "json-xss")
  get "/json/level1/" do |env|
    query = env.params.query["query"]
    callback = env.params.query["callback"]? || "callback"
    env.response.content_type = "application/javascript"
    
    "#{callback}({\"message\": \"#{query}\", \"status\": \"success\"})"
  end

  Xssmaze.push("json-xss-level2", "/json/level2/?query=a", "JSON XSS with HTML entities bypass", "json-xss")
  get "/json/level2/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "application/json"
    
    "{\"html_content\": \"<div>#{query}</div>\", \"escaped\": false}"
  end

  Xssmaze.push("json-xss-level3", "/json/level3/?query=a", "JSON XSS with Unicode escape", "json-xss")
  get "/json/level3/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "application/json"
    
    # Simulate improper Unicode handling
    unicode_query = query.gsub("\\", "\\\\").gsub("\"", "\\\"")
    "{\"data\": \"#{unicode_query}\", \"type\": \"unicode\"}"
  end

  Xssmaze.push("json-xss-level4", "/json/level4/?query=a", "JSON XSS in script tag context", "json-xss")
  get "/json/level4/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>JSON XSS Level 4</h1>
    <script>
      var jsonData = {\"userInput\": \"#{query}\"};
      document.body.innerHTML += '<div>Data: ' + jsonData.userInput + '</div>';
    </script>
    </body></html>"
  end

  Xssmaze.push("json-xss-level5", "/json/level5/?query=a", "JSON XSS with array injection", "json-xss")
  get "/json/level5/" do |env|
    query = env.params.query["query"]
    
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

  Xssmaze.push("json-xss-level6", "/json/level6/?query=a", "JSON XSS with nested object injection", "json-xss")
  get "/json/level6/" do |env|
    query = env.params.query["query"]
    
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
end