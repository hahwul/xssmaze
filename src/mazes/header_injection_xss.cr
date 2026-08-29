# Level 1: Referer header reflected raw in page body
# Bypass: set Referer header to XSS payload
# e.g. Referer: <script>alert(1)</script>
Xssmaze.push("headerinj-level1", "/headerinj/level1/", "referer header reflected raw in body", "GET", ["Referer"],
  vuln: "reflected-html", delivery: ["referer"])
maze_get "/headerinj/level1/" do |env|
  referer = env.request.headers["Referer"]? || ""

  "<html><body><p>You came from: #{referer}</p></body></html>"
end

# Level 2: User-Agent header reflected raw in page body
# Bypass: set User-Agent header to XSS payload
# e.g. User-Agent: <script>alert(1)</script>
Xssmaze.push("headerinj-level2", "/headerinj/level2/", "user-agent header reflected raw in body", "GET", ["User-Agent"],
  vuln: "reflected-html", delivery: ["header"])
maze_get "/headerinj/level2/" do |env|
  ua = env.request.headers["User-Agent"]? || ""

  "<html><body><p>Your browser: #{ua}</p></body></html>"
end

# Level 3: X-Forwarded-For header reflected inside an HTML comment
# Bypass: close the comment with --> then inject HTML
# e.g. X-Forwarded-For: --><script>alert(1)</script><!--
Xssmaze.push("headerinj-level3", "/headerinj/level3/", "x-forwarded-for reflected in HTML comment", "GET", ["X-Forwarded-For"],
  vuln: "reflected-html", delivery: ["header"], note: "lands inside an HTML comment; close it with --> first")
maze_get "/headerinj/level3/" do |env|
  xff = env.request.headers["X-Forwarded-For"]? || ""

  "<html><body><!-- Client IP: #{xff} --><p>Welcome</p></body></html>"
end

# Level 4: Raw Cookie header reflected in page body
# Bypass: set Cookie header to XSS payload
# e.g. Cookie: <script>alert(1)</script>
Xssmaze.push("headerinj-level4", "/headerinj/level4/", "raw cookie header reflected in body", "GET", ["Cookie"],
  vuln: "reflected-html", delivery: ["cookie"], note: "the raw Cookie header is echoed, so the payload need not be a valid cookie pair")
maze_get "/headerinj/level4/" do |env|
  cookie_raw = env.request.headers["Cookie"]? || ""

  "<html><body><p>Session: #{cookie_raw}</p></body></html>"
end

# Level 5: Accept-Language header reflected in a <span lang="QUERY"> attribute
# Bypass: break out of attribute with "> then inject HTML
# e.g. Accept-Language: "><script>alert(1)</script>
Xssmaze.push("headerinj-level5", "/headerinj/level5/", "accept-language reflected in lang attribute", "GET", ["Accept-Language"],
  vuln: "reflected-attr", delivery: ["header"])
maze_get "/headerinj/level5/" do |env|
  lang = env.request.headers["Accept-Language"]? || "en"

  "<html><body><span lang=\"#{lang}\">Localized content</span></body></html>"
end

# Level 6: Custom X-Debug header reflected raw when query param debug=1 is also set
# Bypass: set X-Debug header to XSS payload and add ?debug=1 query param
# e.g. X-Debug: <script>alert(1)</script> with ?debug=1
Xssmaze.push("headerinj-level6", "/headerinj/level6/?debug=1", "x-debug header reflected when debug=1 param set", "GET", ["X-Debug", "debug"],
  vuln: "reflected-html", delivery: ["header"], note: "the header is only reflected when the query string also carries debug=1")
maze_get "/headerinj/level6/" do |env|
  debug = env.params.query["debug"]? || ""
  x_debug = env.request.headers["X-Debug"]? || ""

  if debug == "1"
    "<html><body><p>Debug info: #{x_debug}</p></body></html>"
  else
    "<html><body><p>Debug mode disabled.</p></body></html>"
  end
end
