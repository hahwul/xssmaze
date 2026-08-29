# HTTP QUERY (RFC 10008) reflection.
#
# QUERY is a GET-shaped method — safe and idempotent — that carries its input
# in the request *body* instead of the URL. That combination is exactly what a
# scanner tends to miss: crawlers treat the endpoint as a read, so they probe
# the query string that isn't there, while body-aware probes only fire on
# POST/PUT/PATCH. Every level below is reachable by a plain HTTP client; the
# GET page on the same path is only a browser driver for it.
#
# Kemal answers 400 before the handler when a QUERY request carries a body
# with no `Content-Type`, so each level needs an explicit content type.

# The GET side of every level: a one-field form that sends the value as a
# QUERY request instead of submitting normally.
private def query_driver(path : String, title : String, field : String, json : Bool) : String
  content_type = json ? "application/json" : "application/x-www-form-urlencoded"
  body = json ? "JSON.stringify({#{field}: v})" : "'#{field}=' + encodeURIComponent(v)"

  "<html><body>
  <h1>#{title}</h1>
  <form id='f' onsubmit='send();return false;'>
  <input type='text' name='#{field}' value='a'><input type='submit' value='send QUERY'>
  </form>
  <div id='out'></div>
  <script>
    function send() {
      var v = document.querySelector('input[name=#{field}]').value;
      fetch('#{path}', {
        method: 'QUERY',
        headers: {'Content-Type': '#{content_type}'},
        body: #{body}
      }).then(function (r) { return r.text(); })
        .then(function (t) { document.getElementById('out').innerHTML = t; });
    }
  </script>
  </body></html>"
end

# Level 1: form-encoded QUERY body reflected raw.
# Bypass: <script>alert(1)</script>
Xssmaze.push("querymethod-level1", "/querymethod/level1/", "QUERY form-encoded body param query reflected raw", "QUERY",
  vuln: "reflected-html", delivery: ["body"],
  note: "HTTP QUERY (RFC 10008); send the payload as the request body with Content-Type: application/x-www-form-urlencoded")
maze_get "/querymethod/level1/" do |_|
  query_driver("/querymethod/level1/", "QUERY Method XSS Level 1", "query", false)
end
maze_query "/querymethod/level1/" do |env|
  query = env.params.body.fetch("query", "")

  "<html><body>#{query}</body></html>"
end

# Level 2: JSON QUERY body reflected raw.
# Bypass: <script>alert(1)</script>
Xssmaze.push("querymethod-level2", "/querymethod/level2/", "QUERY JSON body param query reflected raw", "QUERY",
  vuln: "reflected-html", delivery: ["body"],
  note: "HTTP QUERY with Content-Type: application/json; payload goes in {\"query\":\"...\"}")
maze_get "/querymethod/level2/" do |_|
  query_driver("/querymethod/level2/", "QUERY Method XSS Level 2", "query", true)
end
maze_query "/querymethod/level2/" do |env|
  query = env.params.json.fetch("query", "").as(String)

  "<html><body>#{query}</body></html>"
end

# Level 3: QUERY body reflected into an attribute value.
# Bypass: " onfocus=alert(1) autofocus x="
Xssmaze.push("querymethod-level3", "/querymethod/level3/", "QUERY body param query reflected in input value", "QUERY",
  vuln: "reflected-attr", delivery: ["body"],
  note: "HTTP QUERY; attribute breakout out of <input value=\"...\">")
maze_get "/querymethod/level3/" do |_|
  query_driver("/querymethod/level3/", "QUERY Method XSS Level 3", "query", false)
end
maze_query "/querymethod/level3/" do |env|
  query = env.params.body.fetch("query", "")

  "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
end

# Level 4: QUERY body reflected inside a script string literal.
# Bypass: </script><script>alert(1)</script>
Xssmaze.push("querymethod-level4", "/querymethod/level4/", "QUERY body param query reflected in script variable", "QUERY",
  vuln: "reflected-js", delivery: ["body"],
  note: "HTTP QUERY; the value lands inside <script>var q = \"...\";</script>")
maze_get "/querymethod/level4/" do |_|
  query_driver("/querymethod/level4/", "QUERY Method XSS Level 4", "query", false)
end
maze_query "/querymethod/level4/" do |env|
  query = env.params.body.fetch("query", "")

  "<html><body><script>var q = \"#{query}\";</script></body></html>"
end

# Level 5: method confusion — the same path escapes on GET and reflects raw on
# QUERY. A scanner that probes `?query=` only sees the safe branch.
# Bypass: <script>alert(1)</script> in the QUERY body
Xssmaze.push("querymethod-level5", "/querymethod/level5/?query=a", "same path: GET escaped, QUERY body reflected raw", "QUERY",
  vuln: "reflected-html", delivery: ["body"],
  note: "method confusion; GET ?query= is HTML-escaped and safe, only the QUERY body is injectable")
maze_get "/querymethod/level5/" do |env|
  query = Xssmaze.html_escape(env.params.query.fetch("query", "a"))

  "<html><body>
  <p>GET says: #{query}</p>
  <form id='f' onsubmit='send();return false;'>
  <input type='text' name='query' value='a'><input type='submit' value='send QUERY'>
  </form>
  <div id='out'></div>
  <script>
    function send() {
      var v = document.querySelector('input[name=query]').value;
      fetch('/querymethod/level5/', {
        method: 'QUERY',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'query=' + encodeURIComponent(v)
      }).then(function (r) { return r.text(); })
        .then(function (t) { document.getElementById('out').innerHTML = t; });
    }
  </script>
  </body></html>"
end
maze_query "/querymethod/level5/" do |env|
  query = env.params.body.fetch("query", "")

  "<html><body>QUERY says: #{query}</body></html>"
end
