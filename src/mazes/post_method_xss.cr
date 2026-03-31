def load_post_method_xss
  # Level 1: POST body param 'query' reflected raw in response
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("postmethod-level1", "/postmethod/level1/", "POST body param query reflected raw", "POST")
  maze_get "/postmethod/level1/" do |_|
    "<html><body><form action='/postmethod/level1/' method='post'><input type='text' name='query' value='a'><input type='submit'></form></body></html>"
  end
  maze_post "/postmethod/level1/" do |env|
    query = env.params.body["query"].as(String)

    "<html><body>#{query}</body></html>"
  end

  # Level 2: POST body param 'query' reflected in <input value="QUERY">
  # Bypass: " onfocus=alert(1) autofocus x="
  Xssmaze.push("postmethod-level2", "/postmethod/level2/", "POST body param query reflected in input value", "POST")
  maze_get "/postmethod/level2/" do |_|
    "<html><body><form action='/postmethod/level2/' method='post'><input type='text' name='query' value='a'><input type='submit'></form></body></html>"
  end
  maze_post "/postmethod/level2/" do |env|
    query = env.params.body["query"].as(String)

    "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
  end

  # Level 3: POST with Content-Type: application/json body {"query":"QUERY"} reflected raw
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("postmethod-level3", "/postmethod/level3/", "POST JSON body query reflected raw", "POST", ["query"])
  maze_get "/postmethod/level3/" do |_|
    "<html><body><form id='f'><input type='text' name='query' value='a'><input type='submit' onclick='send();return false;'></form>
    <script>function send(){var x=new XMLHttpRequest();x.open('POST','/postmethod/level3/');x.setRequestHeader('Content-Type','application/json;charset=UTF-8');x.send(JSON.stringify({query:document.querySelector('input[name=query]').value}));}</script></body></html>"
  end
  maze_post "/postmethod/level3/" do |env|
    query = env.params.json["query"].as(String)

    "<html><body>#{query}</body></html>"
  end

  # Level 4: POST body param 'query' reflected inside <script>var x = "QUERY";</script>
  # Bypass: close script tag </script><script>alert(1)</script>
  Xssmaze.push("postmethod-level4", "/postmethod/level4/", "POST body param query reflected in script variable", "POST")
  maze_get "/postmethod/level4/" do |_|
    "<html><body><form action='/postmethod/level4/' method='post'><input type='text' name='query' value='a'><input type='submit'></form></body></html>"
  end
  maze_post "/postmethod/level4/" do |env|
    query = env.params.body["query"].as(String)

    "<html><body><script>var x = \"#{query}\";</script></body></html>"
  end

  # Level 5: POST body param 'name' reflected raw (different param name)
  # Bypass: <script>alert(1)</script>
  Xssmaze.push("postmethod-level5", "/postmethod/level5/", "POST body param name reflected raw (non-standard param)", "POST", ["name"])
  maze_get "/postmethod/level5/" do |_|
    "<html><body><form action='/postmethod/level5/' method='post'><input type='text' name='name' value='a'><input type='submit'></form></body></html>"
  end
  maze_post "/postmethod/level5/" do |env|
    query = env.params.body["name"].as(String)

    "<html><body>#{query}</body></html>"
  end

  # Level 6: POST body param 'query' with < > stripped but reflected in <input value="QUERY">
  # Bypass: " onfocus=alert(1) autofocus x=" (no angle brackets needed)
  Xssmaze.push("postmethod-level6", "/postmethod/level6/", "POST body param query in input value with angle bracket filter", "POST")
  maze_get "/postmethod/level6/" do |_|
    "<html><body><form action='/postmethod/level6/' method='post'><input type='text' name='query' value='a'><input type='submit'></form></body></html>"
  end
  maze_post "/postmethod/level6/" do |env|
    query = Filters.strip_angles(env.params.body["query"].as(String))

    "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
  end
end
