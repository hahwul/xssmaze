def load_response_header_xss
  # Level 1: X-Content-Type-Options: nosniff with text/html content type
  # Standard XSS works - nosniff just prevents MIME type sniffing
  Xssmaze.push("respheader-level1", "/respheader/level1/?query=a", "nosniff header with text/html, raw reflection")
  maze_get "/respheader/level1/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["X-Content-Type-Options"] = "nosniff"

    "<html><body>
    <h1>Response Header XSS Level 1</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 2: X-XSS-Protection: 0 - XSS auditor explicitly disabled
  # Standard injection works
  Xssmaze.push("respheader-level2", "/respheader/level2/?query=a", "X-XSS-Protection disabled, raw reflection")
  maze_get "/respheader/level2/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["X-XSS-Protection"] = "0"

    "<html><body>
    <h1>Response Header XSS Level 2</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 3: Cache-Control headers present but query still reflected raw
  # Caching headers have no effect on XSS
  Xssmaze.push("respheader-level3", "/respheader/level3/?query=a", "cache-control headers with raw reflection")
  maze_get "/respheader/level3/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    env.response.headers["Pragma"] = "no-cache"
    env.response.headers["Expires"] = "0"

    "<html><body>
    <h1>Response Header XSS Level 3</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 4: Query reflected in Set-Cookie value AND body
  # Body injection works regardless of cookie setting
  Xssmaze.push("respheader-level4", "/respheader/level4/?query=a", "query in Set-Cookie and body reflection")
  maze_get "/respheader/level4/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.cookies << HTTP::Cookie.new("session_data", query, path: "/respheader/level4/")
    env.response.cookies << HTTP::Cookie.new("user_pref", query, path: "/respheader/level4/")

    "<html><body>
    <h1>Response Header XSS Level 4</h1>
    <div>Your preference: #{query}</div>
    </body></html>"
  end

  # Level 5: CORS header Access-Control-Allow-Origin: * with raw reflection
  # CORS does not prevent XSS in the page itself
  Xssmaze.push("respheader-level5", "/respheader/level5/?query=a", "CORS allow-all with raw reflection")
  maze_get "/respheader/level5/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    env.response.headers["Access-Control-Allow-Headers"] = "Content-Type"

    "<html><body>
    <h1>Response Header XSS Level 5</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 6: All security headers EXCEPT CSP, query reflected raw
  # Without CSP, inline scripts still execute
  Xssmaze.push("respheader-level6", "/respheader/level6/?query=a", "all security headers except CSP, raw reflection")
  maze_get "/respheader/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"
    env.response.headers["X-Content-Type-Options"] = "nosniff"
    env.response.headers["X-Frame-Options"] = "DENY"
    env.response.headers["X-XSS-Protection"] = "0"
    env.response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    env.response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    env.response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"

    "<html><body>
    <h1>Response Header XSS Level 6</h1>
    <div>#{query}</div>
    </body></html>"
  end
end
