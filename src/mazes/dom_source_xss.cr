require "uri"

# DOM taint *sources* the rest of the lab never exercises. Every other
# category here reads location.search / location.hash / postMessage / web
# storage; these seven read from places a source-sink analyzer has to model
# separately — an async IndexedDB cursor, a fragment that is itself a
# querystring, the history entry a popstate returns to, the script element's
# own URL, a Permissions API promise, a CSS custom property, and a genuine
# same-origin WebSocket frame (not a synthetic MessageEvent like the older
# `websocket-xss` / `stream` levels).
#
# The sinks are deliberately boring (innerHTML / insertAdjacentHTML /
# document.write) so that whatever a tool does or does not find is a
# statement about the *source*, not about the sink.

# Level 1: IndexedDB. The value is written to an object store on the seeding
# visit and rendered from the store on every visit afterwards — the read is
# two async callbacks away from the write.
Xssmaze.push("domsource-level1", "/domsource/level1/?query=a", "IndexedDB object-store value (seeded from URL) reflected via innerHTML",
  vuln: "dom", sources: ["indexedDB"], sinks: ["innerHTML"], delivery: ["query"],
  note: "the value is persisted to IndexedDB and read back through two async callbacks; it renders on every later visit even without the parameter")
maze_get "/domsource/level1/" do |_env|
  "<html><body>
  <h1>Saved Note</h1>
  <div id='out'>loading...</div>
  <script>
    var seed = new URLSearchParams(location.search).get('query');
    var open = indexedDB.open('xssmaze-domsource', 1);
    open.onupgradeneeded = function (e) { e.target.result.createObjectStore('notes'); };
    open.onsuccess = function (e) {
      var db = e.target.result;
      function render() {
        var get = db.transaction('notes', 'readonly').objectStore('notes').get('latest');
        get.onsuccess = function (ev) {
          if (ev.target.result != null) {
            document.getElementById('out').innerHTML = ev.target.result;
          }
        };
      }
      if (seed !== null) {
        var tx = db.transaction('notes', 'readwrite');
        tx.objectStore('notes').put(seed, 'latest');
        tx.oncomplete = render;
      } else {
        render();
      }
    };
  </script>
  </body></html>"
end

# Level 2: the fragment parsed as its own querystring. Tools that model
# `location.hash` as one opaque string miss the named key inside it.
Xssmaze.push("domsource-level2", "/domsource/level2/", "URLSearchParams over location.hash reflected via innerHTML", "GET", ["#msg"],
  vuln: "dom", sources: ["location.hash"], sinks: ["innerHTML"], delivery: ["fragment"],
  note: "the fragment is itself a querystring: new URLSearchParams(location.hash.slice(1)).get('msg')")
maze_get "/domsource/level2/" do |_env|
  "<html><body>
  <h1>Fragment Router</h1>
  <div id='out'></div>
  <script>
    // SPA-style hash routing: the fragment carries its own key/value pairs.
    var params = new URLSearchParams(location.hash.slice(1));
    var msg = params.get('msg') || '';
    if (msg) { document.getElementById('out').innerHTML = msg; }
  </script>
  </body></html>"
end

# Level 3: popstate. The payload is stashed on the *current* history entry,
# a throwaway entry is pushed on top, and going back delivers it through the
# popstate event's state object.
Xssmaze.push("domsource-level3", "/domsource/level3/?query=a", "popstate event state round-trip injected via insertAdjacentHTML",
  vuln: "dom", sources: ["popstate", "history.state"], sinks: ["insertAdjacentHTML"], delivery: ["query"],
  note: "the sink only runs from the popstate handler, one history.back() after load")
maze_get "/domsource/level3/" do |_env|
  "<html><body>
  <h1>Back-Button Restore</h1>
  <div id='out'></div>
  <script>
    var seed = new URLSearchParams(location.search).get('query');
    window.addEventListener('popstate', function (e) {
      if (e.state && e.state.html) {
        // Restoring 'what the user was looking at' straight into the DOM.
        document.getElementById('out').insertAdjacentHTML('beforeend', e.state.html);
      }
    });
    if (seed !== null) {
      history.replaceState({ html: seed }, '');
      history.pushState({ html: null }, '');
      setTimeout(function () { history.back(); }, 50);
    }
  </script>
  </body></html>"
end

# Level 4: document.currentScript.src. The external script reads its *own*
# URL for configuration — a real pattern for embeddable widget/tag scripts.
Xssmaze.push("domsource-level4", "/domsource/level4/?query=a", "document.currentScript.src query parameter written via document.write",
  vuln: "dom", sources: ["currentScript.src"], sinks: ["document.write"], delivery: ["query"],
  note: "the server only reflects into the <script src> URL; the taint is read back out of document.currentScript.src by /domsource/level4/boot.js")
maze_get "/domsource/level4/" do |env|
  query = env.params.query.fetch("query", "")
  src = "/domsource/level4/boot.js?msg=#{URI.encode_www_form(query)}"

  "<html><body>
  <h1>Embeddable Widget</h1>
  <script src=\"#{src}\"></script>
  </body></html>"
end

get "/domsource/level4/boot.js" do |env|
  env.response.content_type = "application/javascript; charset=utf-8"
  "// Widget bootstrap: configuration is carried on this script's own URL.
var self = document.currentScript.src;
var msg = new URL(self).searchParams.get('msg') || '';
if (msg) { document.write(msg); }"
end

# Level 5: the sink is only reachable from a Permissions API promise
# callback. Nothing in the synchronous body of the page touches it.
Xssmaze.push("domsource-level5", "/domsource/level5/?query=a", "sink reached only inside a navigator.permissions callback",
  vuln: "dom", sources: ["location.search", "permissions-api"], sinks: ["innerHTML"], delivery: ["query"],
  note: "the innerHTML assignment lives inside navigator.permissions.query().then(); no synchronous path reaches it")
maze_get "/domsource/level5/" do |_env|
  "<html><body>
  <h1>Notification Settings</h1>
  <div id='out'>checking permission...</div>
  <script>
    var msg = new URLSearchParams(location.search).get('query') || '';
    navigator.permissions.query({ name: 'notifications' }).then(function (status) {
      // Render the banner once the permission state is known.
      document.getElementById('out').innerHTML =
        '<span data-state=\"' + status.state + '\">' + msg + '</span>';
    });
  </script>
  </body></html>"
end

# Level 6: a CSS custom property as the carrier. The value round-trips
# through the CSSOM (setProperty -> getComputedStyle -> getPropertyValue)
# before it reaches an HTML sink.
Xssmaze.push("domsource-level6", "/domsource/level6/", "CSS custom property read back via getComputedStyle into insertAdjacentHTML", "GET", ["#hash"],
  vuln: "dom", sources: ["css-custom-property", "location.hash"], sinks: ["insertAdjacentHTML"], delivery: ["fragment"],
  note: "the value is stored in a --custom-property and read back through the CSSOM; avoid quotes and unbalanced brackets so it stays a valid declaration value")
maze_get "/domsource/level6/" do |_env|
  "<html><body>
  <h1>Themed Banner</h1>
  <div id='out'></div>
  <script>
    // Theme engine: stash the label on a custom property, read it back later.
    var raw = decodeURIComponent(location.hash.slice(1));
    if (raw) { document.documentElement.style.setProperty('--maze-label', raw); }
    var label = getComputedStyle(document.documentElement)
      .getPropertyValue('--maze-label').trim();
    if (label) { document.getElementById('out').insertAdjacentHTML('beforeend', label); }
  </script>
  </body></html>"
end

# Level 7: a real same-origin WebSocket. Unlike the synthetic
# `websocket-xss` / `stream` levels (which call onmessage by hand), this one
# actually connects to /domsource/level7/echo and renders the frame the
# server sends back.
Xssmaze.push("domsource-level7", "/domsource/level7/?query=a", "real same-origin WebSocket echo frame reflected via innerHTML",
  vuln: "dom", sources: ["websocket-message"], sinks: ["innerHTML"], delivery: ["query"],
  note: "a genuine WebSocket round-trip through /domsource/level7/echo, not a synthetic MessageEvent")
maze_get "/domsource/level7/" do |_env|
  "<html><body>
  <h1>Live Feed</h1>
  <div id='out'>connecting...</div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var scheme = location.protocol === 'https:' ? 'wss:' : 'ws:';
    var socket = new WebSocket(scheme + '//' + location.host + '/domsource/level7/echo');
    socket.onmessage = function (e) {
      document.getElementById('out').innerHTML = e.data;
    };
    socket.onopen = function () { socket.send(q); };
  </script>
  </body></html>"
end

ws "/domsource/level7/echo" do |socket|
  socket.on_message do |message|
    socket.send(message)
  end
end
