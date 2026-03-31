def load_sink_xss
  # Level 1: Reflection in <a> href with onclick handler
  Xssmaze.push("sink-level1", "/sink/level1/?query=a", "href with onclick JS handler")
  maze_get "/sink/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"#\" onclick=\"location='#{query}'\">Go</a></body></html>"
  end

  # Level 2: window.location assignment in script (reflected XSS via redirect)
  Xssmaze.push("sink-level2", "/sink/level2/?query=a", "script location assignment")
  maze_get "/sink/level2/" do |env|
    query = env.params.query["query"]
    escaped = query.gsub("\"", "\\\"")

    "<script>if(false) window.location = \"#{escaped}\";</script>"
  end

  # Level 3: Reflection in form action attribute
  Xssmaze.push("sink-level3", "/sink/level3/?query=a", "form action attribute injection")
  maze_get "/sink/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><form action=\"#{query}\" method=\"get\"><input type=\"submit\" value=\"Go\"></form></body></html>"
  end

  # Level 4: Reflection in embed src
  Xssmaze.push("sink-level4", "/sink/level4/?query=a", "embed src attribute injection")
  maze_get "/sink/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><embed src=\"#{query}\" type=\"text/html\"></body></html>"
  end

  # Level 5: Reflection in link tag href (stylesheet context)
  Xssmaze.push("sink-level5", "/sink/level5/?query=a", "link stylesheet href injection")
  maze_get "/sink/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><link rel=\"stylesheet\" href=\"#{query}\"></head><body>Page</body></html>"
  end

  # Level 6: Reflection in data-* attribute (JS reads and uses innerHTML)
  Xssmaze.push("sink-level6", "/sink/level6/?query=a", "data attribute to innerHTML pipeline")
  maze_get "/sink/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div id=\"target\" data-content=\"#{query}\"></div>
    <script>
    document.getElementById('target').innerHTML = document.getElementById('target').dataset.content;
    </script>
    </body></html>"
  end

  # Level 7: Reflection in textarea + form submission XSS
  Xssmaze.push("sink-level7", "/sink/level7/?query=a", "textarea value with form action")
  maze_get "/sink/level7/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <form action=\"/sink/level7/result\" method=\"get\">
    <textarea name=\"msg\">#{query}</textarea>
    <input type=\"submit\">
    </form>
    </body></html>"
  end

  # Level 8: JSON response with Content-Type text/html (JSONP-like)
  Xssmaze.push("sink-level8", "/sink/level8/?callback=render", "JSONP-like with text/html content-type")
  maze_get "/sink/level8/" do |env|
    callback = env.params.query.fetch("callback", "callback")
    env.response.content_type = "text/html"

    "#{callback}({\"status\":\"ok\"})"
  end
end
