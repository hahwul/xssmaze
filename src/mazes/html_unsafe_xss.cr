# Native "unsafe" HTML-parsing sinks that shipped across browsers in 2024
# (Chrome 124+, Firefox 123+, Safari 17.4): Element.setHTMLUnsafe(),
# Document.parseHTMLUnsafe(), and ShadowRoot.setHTMLUnsafe(). Each parses a
# string into live DOM *without* sanitization — the "Unsafe" suffix is the
# whole point: the safe siblings (setHTML / Document.parseHTML) run a built-in
# Sanitizer, these deliberately do not. For XSS they behave exactly like
# innerHTML — an inline <script> stays inert, but <img onerror> / <svg onload>
# fire. Apps reach for them to render declarative shadow DOM, which innerHTML
# cannot do, so adoption is growing. A DOM-aware scanner that already models
# innerHTML as a sink should treat these identically; static sink lists that
# don't yet know the new method names will miss them, which is exactly the
# coverage gap this category measures.

# Level 1: Element.setHTMLUnsafe() fed from location.hash — the canonical
# client-side source -> new sink flow, no quote breakout needed.
Xssmaze.push("htmlunsafe-level1", "/htmlunsafe/level1/", "Element.setHTMLUnsafe() of location.hash", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["setHTMLUnsafe"], delivery: ["fragment"], note: "setHTMLUnsafe parses HTML with no sanitizer; <img onerror>/<svg onload> fire, inline <script> stays inert")
maze_get "/htmlunsafe/level1/" do |_env|
  "<html><body>
  <h1>Preview</h1>
  <div id='out'></div>
  <script>
    var html = decodeURIComponent(location.hash.slice(1));
    // setHTMLUnsafe parses HTML with no sanitizer; onerror/onload execute.
    document.getElementById('out').setHTMLUnsafe(html);
  </script>
  </body></html>"
end

# Level 2: Element.setHTMLUnsafe() fed from a location.search query param.
Xssmaze.push("htmlunsafe-level2", "/htmlunsafe/level2/?query=a", "Element.setHTMLUnsafe() of a location.search value",
  vuln: "dom", sources: ["location.search"], sinks: ["setHTMLUnsafe"], delivery: ["query"], note: "the query param is read client-side and passed to setHTMLUnsafe")
maze_get "/htmlunsafe/level2/" do |_env|
  "<html><body>
  <h1>Notes</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    document.getElementById('out').setHTMLUnsafe(q);
  </script>
  </body></html>"
end

# Level 3: server-reflected value inlined into a JS string then handed to
# setHTMLUnsafe(). The reflection is visible in the served HTML source, so
# this is detectable as a reflected sink too.
Xssmaze.push("htmlunsafe-level3", "/htmlunsafe/level3/?query=a", "server-reflected string passed to setHTMLUnsafe()",
  vuln: "reflected-js", sinks: ["setHTMLUnsafe"], delivery: ["query"], note: "server reflects raw into a single-quoted JS string that is then passed to setHTMLUnsafe; break out with a single quote")
maze_get "/htmlunsafe/level3/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><body>
  <h1>Message</h1>
  <div id='out'></div>
  <script>
    var msg = '#{query}';
    document.getElementById('out').setHTMLUnsafe(msg);
  </script>
  </body></html>"
end

# Level 4: Document.parseHTMLUnsafe() builds a detached Document from the
# string; its parsed body nodes are then adopted into the live page.
Xssmaze.push("htmlunsafe-level4", "/htmlunsafe/level4/?query=a", "Document.parseHTMLUnsafe() result appended to the page",
  vuln: "dom", sources: ["location.search"], sinks: ["parseHTMLUnsafe"], delivery: ["query"], note: "query read client-side, parsed by Document.parseHTMLUnsafe, then adopted into the page")
maze_get "/htmlunsafe/level4/" do |_env|
  "<html><body>
  <h1>Importer</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var doc = Document.parseHTMLUnsafe(q);
    document.getElementById('out').append(...doc.body.childNodes);
  </script>
  </body></html>"
end

# Level 5: ShadowRoot.setHTMLUnsafe() — the same sink on a web component's
# shadow root, a common place real code reaches for the Unsafe variant.
Xssmaze.push("htmlunsafe-level5", "/htmlunsafe/level5/", "ShadowRoot.setHTMLUnsafe() of location.hash", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["setHTMLUnsafe"], delivery: ["fragment"], note: "ShadowRoot.setHTMLUnsafe; fires inside the shadow root")
maze_get "/htmlunsafe/level5/" do |_env|
  "<html><body>
  <h1>Widget</h1>
  <div id='host'></div>
  <script>
    var root = document.getElementById('host').attachShadow({ mode: 'open' });
    var html = decodeURIComponent(location.hash.slice(1));
    // <img onerror> fires inside a shadow root just as in the light DOM.
    root.setHTMLUnsafe(html);
  </script>
  </body></html>"
end

# Level 6: Document.parseHTMLUnsafe() of an async fetch() API response — ties
# the new sink to the modern fetch-response-into-sink data flow. The companion
# /api route echoes the forwarded param raw as text/html.
Xssmaze.push("htmlunsafe-level6", "/htmlunsafe/level6/?query=a", "Document.parseHTMLUnsafe() of a fetch() API response",
  vuln: "dom", sources: ["location.search", "fetch-response"], sinks: ["parseHTMLUnsafe"], delivery: ["query"], note: "query is forwarded to the level6 api, which echoes it raw as text/html; the fetch response is parsed by parseHTMLUnsafe")
maze_get "/htmlunsafe/level6/" do |_env|
  "<html><body>
  <h1>Feed</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    fetch('/htmlunsafe/level6/api?query=' + encodeURIComponent(q))
      .then(function (r) { return r.text(); })
      .then(function (t) {
        var doc = Document.parseHTMLUnsafe(t);
        document.getElementById('out').append(...doc.body.childNodes);
      });
  </script>
  </body></html>"
end

get "/htmlunsafe/level6/api" do |env|
  q = env.params.query.fetch("query", "")
  env.response.content_type = "text/html; charset=utf-8"
  "<section>#{q}</section>"
end
