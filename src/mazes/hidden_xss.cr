Xssmaze.push("hidden-xss-level1", "/hidden/level1/?query=a", "input-hidden",
  vuln: "reflected-attr", delivery: ["query"], note: "type=hidden, so break out of the value attribute into a new tag rather than adding a handler to this element")
maze_get "/hidden/level1/" do |env|
  query = env.params.query.fetch("query", "")

  "<input type=\"hidden\" value=\"#{query}\">"
end

Xssmaze.push("hidden-xss-level2", "/hidden/level2/?query=a", "input-hidden and escape < >",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are stripped and the input is type=hidden, whose duplicate type attribute the parser drops; the remaining vector is an injected accesskey plus a handler, which needs Firefox and an Alt+Shift keypress")
maze_get "/hidden/level2/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))

  "<input type=\"hidden\" value=\"#{query}\">"
end

Xssmaze.push("hidden-xss-level3", "/hidden/level3/?query=a", "input-hidden and escape < > and space",
  vuln: "reflected-attr", delivery: ["query"], note: "as level2, plus spaces are stripped, so separate the injected attributes with / or a tab")
maze_get "/hidden/level3/" do |env|
  query = Filters.strip_angles(env.params.query.fetch("query", ""))
  query = Filters.strip_spaces(query)

  "<input type=\"hidden\" value=\"#{query}\">"
end
