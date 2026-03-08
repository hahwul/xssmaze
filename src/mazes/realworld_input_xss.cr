def load_realworld_input
  # Level 1: X-Forwarded-For header reflection in error page
  # Common in reverse proxy setups where the header is logged/displayed
  Xssmaze.push("realworld_input-level1", "/realworld-input/level1/", "X-Forwarded-For header reflection")
  maze_get "/realworld-input/level1/" do |env|
    xff = env.request.headers.fetch("X-Forwarded-For", "127.0.0.1")

    "<html><body><h1>403 Forbidden</h1><p>Access denied for IP: #{xff}</p></body></html>"
  end

  # Level 2: POST JSON body reflection
  # Accepts JSON body with {"name": "value"} and reflects without escaping
  Xssmaze.push("realworld_input-level2", "/realworld-input/level2/", "POST JSON body reflection (name field)")
  maze_get "/realworld-input/level2/" do |_|
    "<html><body><h2>API Endpoint</h2><p>POST JSON with {\"name\": \"value\"}</p></body></html>"
  end
  maze_post "/realworld-input/level2/" do |env|
    name = env.params.json["name"].as(String)

    "<html><body><h2>Hello, #{name}!</h2></body></html>"
  end

  # Level 3: POST multipart form reflection
  # Reflects a form field from multipart/form-data upload
  Xssmaze.push("realworld_input-level3", "/realworld-input/level3/", "POST multipart form field reflection")
  maze_get "/realworld-input/level3/" do |_|
    "<html><body><form action='/realworld-input/level3/' method='post' enctype='multipart/form-data'><input type='text' name='username' value='test'><input type='file' name='avatar'><input type='submit' value='Upload'></form></body></html>"
  end
  maze_post "/realworld-input/level3/" do |env|
    username = env.params.body.fetch("username", "anonymous")

    "<html><body><h2>Profile updated for: #{username}</h2></body></html>"
  end

  # Level 4: Location header injection via parameter
  # Redirects to user-controlled URL; javascript: protocol triggers XSS
  Xssmaze.push("realworld_input-level4", "/realworld-input/level4/?url=https://example.com", "Location header redirect (javascript: sink)")
  maze_get "/realworld-input/level4/" do |env|
    url = env.params.query.fetch("url", "/")
    env.response.headers["Location"] = url
    env.response.status_code = 302

    ""
  end

  # Level 5: Meta refresh redirect
  # Uses <meta http-equiv="refresh"> with user-controlled URL
  Xssmaze.push("realworld_input-level5", "/realworld-input/level5/?url=https://example.com", "meta refresh redirect sink")
  maze_get "/realworld-input/level5/" do |env|
    url = env.params.query.fetch("url", "/")

    "<html><head><meta http-equiv=\"refresh\" content=\"0;url=#{url}\"></head><body>Redirecting...</body></html>"
  end

  # Level 6: Cookie value reflection
  # First request sets cookie from query param, subsequent requests reflect cookie value
  Xssmaze.push("realworld_input-level6", "/realworld-input/level6/?lang=en", "cookie value reflection (stored via param)")
  maze_get "/realworld-input/level6/" do |env|
    lang_param = env.params.query.fetch("lang", "")

    unless lang_param.empty?
      env.response.cookies << HTTP::Cookie.new("lang", lang_param, path: "/realworld-input/level6/")
    end

    lang_cookie = ""
    if cookie = env.request.cookies["lang"]?
      lang_cookie = cookie.value
    end

    # If param was just set, use it directly (reflects on same request)
    display = lang_param.empty? ? lang_cookie : lang_param

    "<html><body><div>Current language: #{display}</div></body></html>"
  end

  # Level 7: Full URL / path reflection in link tag
  # Allows injection via path: /realworld-input/level7/"><script>alert(1)</script>
  Xssmaze.push("realworld_input-level7", "/realworld-input/level7/test", "path reflection in link href")
  maze_get "/realworld-input/level7/:path" do |env|
    path = env.params.url["path"]

    "<html><head><link rel=\"canonical\" href=\"/realworld-input/level7/#{path}\"></head><body>Page: #{Filters.strip_angles(path)}</body></html>"
  end

  # Level 8: JSONP callback injection
  # Returns callback({"data":"value"}) with application/javascript content-type
  Xssmaze.push("realworld_input-level8", "/realworld-input/level8/?callback=myFunc", "JSONP callback injection")
  maze_get "/realworld-input/level8/" do |env|
    callback = env.params.query.fetch("callback", "callback")
    env.response.content_type = "application/javascript"

    "#{callback}({\"data\":\"value\"})"
  end
end
