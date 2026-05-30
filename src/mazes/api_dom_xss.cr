require "json"

# Reflected DOM XSS via client-side API responses — the dominant modern-SPA
# shape. The page reads a URL param, fetches a same-origin API that echoes it,
# and drops the response into an HTML sink. The bug only exists end-to-end:
# the API alone returns a correct (json/plain) content type, so it is not XSS
# on its own. This exercises a scanner's ability to follow the async
# fetch()/XHR data flow from the network response into the sink.
#
# Each /apidom/levelN/ page has a companion /apidom/levelN/api echo route
# (not listed in the maze map) that reflects the forwarded `q` raw.

# Level 1: fetch() text response -> innerHTML
Xssmaze.push("apidom-level1", "/apidom/level1/?q=a", "fetch() text response reflected via innerHTML", "GET", ["q"])
maze_get "/apidom/level1/" do |_env|
  "<html><body>
  <h1>Search</h1>
  <div id='out'>loading...</div>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    fetch('/apidom/level1/api?q=' + encodeURIComponent(q))
      .then(function (r) { return r.text(); })
      .then(function (t) { document.getElementById('out').innerHTML = t; });
  </script>
  </body></html>"
end

get "/apidom/level1/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "text/plain; charset=utf-8"
  "You searched for: #{q}"
end

# Level 2: fetch() JSON field -> innerHTML
Xssmaze.push("apidom-level2", "/apidom/level2/?q=a", "fetch() JSON field reflected via innerHTML", "GET", ["q"])
maze_get "/apidom/level2/" do |_env|
  "<html><body>
  <h1>Profile Card</h1>
  <div id='card'>loading...</div>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    fetch('/apidom/level2/api?q=' + encodeURIComponent(q))
      .then(function (r) { return r.json(); })
      .then(function (d) { document.getElementById('card').innerHTML = d.html; });
  </script>
  </body></html>"
end

get "/apidom/level2/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "application/json"
  {html: q}.to_json
end

# Level 3: XMLHttpRequest responseText -> innerHTML
Xssmaze.push("apidom-level3", "/apidom/level3/?q=a", "XMLHttpRequest responseText reflected via innerHTML", "GET", ["q"])
maze_get "/apidom/level3/" do |_env|
  "<html><body>
  <h1>Status</h1>
  <div id='out'>loading...</div>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/apidom/level3/api?q=' + encodeURIComponent(q));
    xhr.onload = function () { document.getElementById('out').innerHTML = xhr.responseText; };
    xhr.send();
  </script>
  </body></html>"
end

get "/apidom/level3/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "text/html; charset=utf-8"
  "<span>Status for #{q}</span>"
end

# Level 4: fetch() JSON field -> insertAdjacentHTML
Xssmaze.push("apidom-level4", "/apidom/level4/?q=a", "fetch() JSON field injected via insertAdjacentHTML", "GET", ["q"])
maze_get "/apidom/level4/" do |_env|
  "<html><body>
  <h1>Notifications</h1>
  <ul id='feed'></ul>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    fetch('/apidom/level4/api?q=' + encodeURIComponent(q))
      .then(function (r) { return r.json(); })
      .then(function (d) {
        document.getElementById('feed').insertAdjacentHTML('beforeend', '<li>' + d.msg + '</li>');
      });
  </script>
  </body></html>"
end

get "/apidom/level4/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "application/json"
  {msg: q}.to_json
end

# Level 5: fetch() text response -> document.write
Xssmaze.push("apidom-level5", "/apidom/level5/?q=a", "fetch() text response written via document.write", "GET", ["q"])
maze_get "/apidom/level5/" do |_env|
  "<html><body>
  <h1>Widget</h1>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    fetch('/apidom/level5/api?q=' + encodeURIComponent(q))
      .then(function (r) { return r.text(); })
      .then(function (t) { document.write(t); });
  </script>
  </body></html>"
end

get "/apidom/level5/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "text/plain; charset=utf-8"
  "<div>Widget: #{q}</div>"
end

# Level 6: fetch() text response -> Range.createContextualFragment + append
Xssmaze.push("apidom-level6", "/apidom/level6/?q=a", "fetch() response parsed via createContextualFragment then appended", "GET", ["q"])
maze_get "/apidom/level6/" do |_env|
  "<html><body>
  <h1>Fragment Loader</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('q') || '';
    fetch('/apidom/level6/api?q=' + encodeURIComponent(q))
      .then(function (r) { return r.text(); })
      .then(function (t) {
        var frag = document.createRange().createContextualFragment(t);
        document.getElementById('out').appendChild(frag);
      });
  </script>
  </body></html>"
end

get "/apidom/level6/api" do |env|
  q = env.params.query.fetch("q", "")
  env.response.content_type = "text/html; charset=utf-8"
  "<section>#{q}</section>"
end
