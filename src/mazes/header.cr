Xssmaze.push("header-level1", "/header/level1/", "referer header", "GET", ["Referer"],
  vuln: "reflected-html", delivery: ["referer"], note: "the whole Referer header is echoed as the entire text/html response body")
maze_get "/header/level1/" do |env|
  env.request.headers["Referer"]? || ""
end

Xssmaze.push("header-level2", "/header/level2/", "user-agent header", "GET", ["User-Agent"],
  vuln: "reflected-html", delivery: ["header"])
maze_get "/header/level2/" do |env|
  env.request.headers["User-Agent"]? || ""
end

Xssmaze.push("header-level3", "/header/level3/", "authorization header", "GET", ["Authorization"],
  vuln: "reflected-html", delivery: ["header"])
maze_get "/header/level3/" do |env|
  env.request.headers["Authorization"]? || ""
end

Xssmaze.push("header-level4", "/header/level4/", "cookie header", "GET", ["Cookie"],
  vuln: "reflected-html", delivery: ["cookie"], note: "the raw Cookie request header is echoed verbatim, so the payload does not have to be a valid cookie pair")
maze_get "/header/level4/" do |env|
  env.request.headers["Cookie"]? || ""
end
