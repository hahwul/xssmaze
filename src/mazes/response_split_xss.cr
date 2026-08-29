# Level 1: Reflection in HTTP header (X-Custom) + body
Xssmaze.push("rsplit-level1", "/rsplit/level1/?query=a", "reflection in custom header + body",
  vuln: "reflected-html", delivery: ["query"], note: "the X-Search-Term header copy strips CR/LF (no response splitting); the body reflection is a raw HTML injection")
maze_get "/rsplit/level1/" do |env|
  query = env.params.query.fetch("query", "a")
  # Reflected raw into the body below; the header copy drops CR/LF only
  # because Crystal refuses to emit them (it raises instead of splitting).
  env.response.headers["X-Search-Term"] = Xssmaze.header_value(query)

  "<html><body><h1>Search: #{query}</h1></body></html>"
end

# Level 2: Two different params, different contexts
Xssmaze.push("rsplit-level2", "/rsplit/level2/?name=a&color=blue", "two params: body + style attribute",
  vuln: "reflected-html", params: ["name", "color"], delivery: ["query"], note: "name lands in the body (raw), color in a style attribute; both exploitable")
maze_get "/rsplit/level2/" do |env|
  name = env.params.query.fetch("name", "a")
  color = env.params.query.fetch("color", "blue")

  "<html><body><div style=\"color: #{color}\">Hello, #{name}!</div></body></html>"
end

# Level 3: Error page reflection (search term in error message)
Xssmaze.push("rsplit-level3", "/rsplit/level3/?page=test", "error message query reflection",
  vuln: "reflected-html", params: ["page"], delivery: ["query"], note: "reflects the page parameter into the error text")
maze_get "/rsplit/level3/" do |env|
  page = env.params.query.fetch("page", "unknown")

  "<html><body><h1>Error: Not Found</h1><p>The page '#{page}' was not found on this server.</p></body></html>"
end

# Level 4: Reflection in Set-Cookie + body
Xssmaze.push("rsplit-level4", "/rsplit/level4/?pref=a", "set-cookie + body reflection",
  vuln: "reflected-html", params: ["pref"], delivery: ["query"], note: "the cookie copy strips RFC 6265-forbidden bytes; the body reflection is a raw HTML injection")
maze_get "/rsplit/level4/" do |env|
  pref = env.params.query.fetch("pref", "default")
  # Splitting characters are exactly what this level is about, so the cookie
  # copy keeps everything RFC 6265 lets through and the body keeps the rest.
  env.response.cookies << HTTP::Cookie.new("pref", Xssmaze.cookie_value(pref), path: "/rsplit/level4/")

  "<html><body><div>Preference: #{pref}</div></body></html>"
end
