# Level 1: JSONP callback with alphanumeric filter only
Xssmaze.push("callback-level1", "/callback/level1/?callback=myFunc", "JSONP with no callback filter", "GET", ["callback"],
  vuln: "reflected-js", delivery: ["query"], note: "served as application/javascript, so it executes in a page that loads this URL with <script src>, not on direct navigation")
maze_get "/callback/level1/" do |env|
  callback = env.params.query.fetch("callback", "callback")
  env.response.content_type = "application/javascript"

  "/**/ typeof #{callback} === 'function' && #{callback}({\"data\":\"test\"})"
end

# Level 2: JSONP with ( ) stripped from callback
Xssmaze.push("callback-level2", "/callback/level2/?callback=myFunc", "JSONP with parens stripped from callback", "GET", ["callback"],
  vuln: "reflected-js", delivery: ["query"], note: "same script-include reach as level1; parens are stripped, so call through tagged-template syntax instead")
maze_get "/callback/level2/" do |env|
  callback = Filters.strip_parens(env.params.query.fetch("callback", "callback"))
  env.response.content_type = "application/javascript"

  "#{callback}({\"data\":\"test\"})"
end

# Level 3: Callback in script tag (HTML context)
Xssmaze.push("callback-level3", "/callback/level3/?fn=render", "callback in inline script tag", "GET", ["fn"],
  vuln: "reflected-js", delivery: ["query"], note: "the injectable parameter is fn; it lands as a bare statement in an inline script of an HTML page, so no quote breakout is needed")
maze_get "/callback/level3/" do |env|
  fn_name = env.params.query.fetch("fn", "render")

  "<html><body>
  <script>
  function render(data) { document.body.innerHTML += data.msg; }
  #{fn_name}({\"msg\": \"Hello\"});
  </script>
  </body></html>"
end

# Level 4: Event stream callback name injection
Xssmaze.push("callback-level4", "/callback/level4/?handler=onData", "event handler name injection", "GET", ["handler"],
  vuln: "reflected-js", delivery: ["query"], note: "the injectable parameter is handler; it lands inside a single-quoted property name in window['...']")
maze_get "/callback/level4/" do |env|
  handler = env.params.query.fetch("handler", "onData")

  "<html><body>
  <div id='output'></div>
  <script>
  window['#{handler}'] = function(e) { document.getElementById('output').textContent = e; };
  window['#{handler}']('test event');
  </script>
  </body></html>"
end
