XSLEAK_ROLE_COOKIE = "xsleak_role"
XSLEAK_1X1_GIF = Bytes[
  0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00, 0x00,
  0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x21, 0xF9, 0x04, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x2C, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02,
  0x44, 0x01, 0x00, 0x3B,
]

def xsleak_admin?(env) : Bool
  q = env.params.query["q"]?
  role = env.request.cookies[XSLEAK_ROLE_COOKIE]?.try(&.value)
  q == "admin" || role == "admin"
end

def xsleak_no_store(env)
  env.response.headers["Cache-Control"] = "no-store"
end

maze_get "/xsleak/" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/html; charset=utf-8"
  role = env.request.cookies[XSLEAK_ROLE_COOKIE]?.try(&.value) || "guest"
  "<!doctype html><html><head><meta charset='UTF-8'><title>XS-Leaks - XSSMaze</title></head><body>" \
  "<h1>XS-Leaks (Cross-Site Leaks)</h1>" \
  "<p>role cookie: <strong>#{Xssmaze.html_escape(role)}</strong></p>" \
  "<ul>" \
  "<li><a href='/xsleak/login?as=admin'>login as admin</a></li>" \
  "<li><a href='/xsleak/login?as=guest'>login as guest</a></li>" \
  "<li><a href='/xsleak/logout'>logout</a></li>" \
  "</ul>" \
  "<p>Try the levels via <code>/map/*</code> or these links:</p>" \
  "<ul>" \
  "<li><a href='/xsleak/search?q=admin'>/xsleak/search?q=admin</a></li>" \
  "<li><a href='/xsleak/frame?q=admin'>/xsleak/frame?q=admin</a></li>" \
  "<li><a href='/xsleak/avatar.gif?q=admin'>/xsleak/avatar.gif?q=admin</a></li>" \
  "<li><a href='/xsleak/timing?q=admin'>/xsleak/timing?q=admin</a></li>" \
  "<li><a href='/xsleak/redirect?q=admin'>/xsleak/redirect?q=admin</a></li>" \
  "</ul>" \
  "</body></html>"
end

maze_get "/xsleak/login" do |env|
  xsleak_no_store(env)
  as = env.params.query["as"]?
  role = as == "admin" ? "admin" : "guest"
  env.response.cookies << HTTP::Cookie.new(XSLEAK_ROLE_COOKIE, role, path: "/xsleak/")
  env.redirect "/xsleak/"
  ""
end

maze_get "/xsleak/logout" do |env|
  xsleak_no_store(env)
  env.response.cookies << HTTP::Cookie.new(XSLEAK_ROLE_COOKIE, "", path: "/xsleak/", expires: Time.utc - 1.day)
  env.redirect "/xsleak/"
  ""
end

maze_get "/xsleak/empty" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/html; charset=utf-8"
  "<!doctype html><html><head><meta charset='UTF-8'><title>empty</title></head><body>ok</body></html>"
end

# Level 1: Body size oracle (admin vs guest)
Xssmaze.push("xsleak-level1", "/xsleak/search?q=admin", "body size oracle (admin returns more results)", "GET", ["q"])
maze_get "/xsleak/search" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/html; charset=utf-8"

  admin = xsleak_admin?(env)
  results = admin ? 60 : 6
  filler = admin ? 200 : 0

  String.build do |io|
    io << "<!doctype html><html><head><meta charset='UTF-8'><title>Search</title></head><body>"
    io << "<h1>Search</h1>"
    io << "<p>q=" << Xssmaze.html_escape(env.params.query["q"]? || "") << "</p>"
    io << "<ul>"
    results.times do |i|
      io << "<li>Result " << (i + 1).to_s << "</li>"
    end
    io << "</ul>"
    if filler > 0
      io << "<div style='display:none'>"
      filler.times { io << "A" * 50 }
      io << "</div>"
    end
    io << "</body></html>"
  end
end

# Level 2: Frame-count oracle (admin includes more subframes)
Xssmaze.push("xsleak-level2", "/xsleak/frame?q=admin", "frame-count oracle (admin includes more iframes)", "GET", ["q"])
maze_get "/xsleak/frame" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/html; charset=utf-8"

  admin = xsleak_admin?(env)
  frame_count = admin ? 12 : 1

  String.build do |io|
    io << "<!doctype html><html><head><meta charset='UTF-8'><title>Frames</title></head><body>"
    io << "<h1>Frames</h1>"
    io << "<p>frames=" << frame_count.to_s << "</p>"
    frame_count.times do
      io << "<iframe src='/xsleak/empty' style='width:0;height:0;border:0'></iframe>"
    end
    io << "</body></html>"
  end
end

# Level 3: Load/error oracle (image 200 vs 404)
Xssmaze.push("xsleak-level3", "/xsleak/avatar.gif?q=admin", "image load oracle (admin returns valid image, guest 404)", "GET", ["q"])
maze_get "/xsleak/avatar.gif" do |env|
  xsleak_no_store(env)
  if xsleak_admin?(env)
    env.response.content_type = "image/gif"
    env.response.write(XSLEAK_1X1_GIF)
    ""
  else
    env.response.status_code = 404
    env.response.content_type = "text/plain; charset=utf-8"
    "not found"
  end
end

# Level 4: Timing oracle (guest path is slower)
Xssmaze.push("xsleak-level4", "/xsleak/timing?q=admin", "timing oracle (guest responds slower)", "GET", ["q"])
maze_get "/xsleak/timing" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/plain; charset=utf-8"

  admin = xsleak_admin?(env)
  sleep(admin ? 0.01 : 0.25)
  "ok"
end

# Level 5: Redirect-chain oracle (admin has more hops)
Xssmaze.push("xsleak-level5", "/xsleak/redirect?q=admin", "redirect-chain oracle (admin follows more redirects)", "GET", ["q"])
maze_get "/xsleak/redirect" do |env|
  xsleak_no_store(env)
  hops = xsleak_admin?(env) ? 5 : 1
  env.redirect "/xsleak/redirect/chain?i=1&n=#{hops}"
  ""
end

maze_get "/xsleak/redirect/chain" do |env|
  xsleak_no_store(env)
  env.response.content_type = "text/plain; charset=utf-8"

  i = env.params.query["i"]?.try(&.to_i?) || 1
  n = env.params.query["n"]?.try(&.to_i?) || 1
  if i < n
    env.redirect "/xsleak/redirect/chain?i=#{i + 1}&n=#{n}"
    ""
  else
    "done"
  end
end

