# jQuery DOM sinks: real-world XSS through dangerous jQuery APIs that
# DOM-aware scanners enumerate. jQuery is still pervasive in legacy and
# CMS-driven apps, and each level here isolates a distinct sink *class*
# (selector-to-HTML, parseHTML, DOM insertion, attribute, eval, property
# object) so the param source + jQuery sink pattern is detectable.

# Level 1: $(htmlString) — a string starting with "<" makes jQuery build
# DOM nodes instead of running a selector. Classic scroll-to / tab plugins
# do $(location.hash.slice(1)), turning the fragment into live HTML.
Xssmaze.push("jquery-level1", "/jquery/level1/", "jQuery $() selector turns location.hash into HTML (element creation)", "GET", ["#hash"])
maze_get "/jquery/level1/" do |_env|
  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery Selector Sink</h1>
  <div id='content'></div>
  <script>
    // Scroll-to-target helper: jQuery parses a leading-'<' string as HTML.
    var target = decodeURIComponent(location.hash.slice(1));
    if (target) { $(target).appendTo('#content'); }
  </script>
  </body></html>"
end

# Level 2: $.parseHTML() explicitly parses a string into DOM nodes. The
# query lands in a single-quoted JS string and is then parsed + appended,
# so <img onerror> fires without any quote breakout.
Xssmaze.push("jquery-level2", "/jquery/level2/?query=a", "jQuery $.parseHTML() of reflected string then append")
maze_get "/jquery/level2/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery parseHTML Sink</h1>
  <div id='out'></div>
  <script>
    var raw = '#{query}';
    // $.parseHTML keeps event-handler attributes; the nodes execute on insert.
    var nodes = $.parseHTML(raw);
    $('#out').append(nodes);
  </script>
  </body></html>"
end

# Level 3: .append() DOM-insertion sink fed from location.search read on
# the client. Covers the whole .html/.append/.prepend/.before/.after/
# .replaceWith family that all route through jQuery's HTML parser.
Xssmaze.push("jquery-level3", "/jquery/level3/?query=a", "jQuery .append() of location.search value (DOM insertion)")
maze_get "/jquery/level3/" do |_env|
  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery Insertion Sink</h1>
  <ul id='feed'></ul>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    // Building markup by string concat then handing it to .append().
    $('#feed').append('<li>Result: ' + q + '</li>');
  </script>
  </body></html>"
end

# Level 4: .attr('href', ...) lets a javascript: URL reach a navigable
# anchor. The query is reflected into a JS string and assigned as href;
# clicking (or auto-trigger) runs the scheme.
Xssmaze.push("jquery-level4", "/jquery/level4/?query=a", "jQuery .attr('href', ...) sets javascript: URL on an anchor")
maze_get "/jquery/level4/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery Attribute Sink</h1>
  <a id='download'>Download report</a>
  <script>
    // jQuery does not validate the scheme passed to .attr('href', ...).
    $('#download').attr('href', '#{query}');
  </script>
  </body></html>"
end

# Level 5: $.globalEval() is jQuery's wrapper around eval in the global
# scope. Reflected text handed straight to it executes as JavaScript.
Xssmaze.push("jquery-level5", "/jquery/level5/?query=a", "jQuery $.globalEval() executes reflected string as JS")
maze_get "/jquery/level5/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery globalEval Sink</h1>
  <div id='status'>loading config...</div>
  <script>
    var code = '#{query}';
    // Legacy 'plugin config' pattern: evaluate a snippet in global scope.
    $.globalEval(code);
  </script>
  </body></html>"
end

# Level 6: $('<tag>', props) — when the second argument is a plain object,
# jQuery treats keys matching jQuery.fn methods specially. The `html` key
# calls .html(value), so it becomes an innerHTML sink even though the
# value looks like a harmless attribute map.
Xssmaze.push("jquery-level6", "/jquery/level6/?query=a", "jQuery $('<tag>', {html: ...}) property-object innerHTML sink")
maze_get "/jquery/level6/" do |env|
  query = env.params.query.fetch("query", "")

  "<html><head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
  <body>
  <h1>jQuery Property-Object Sink</h1>
  <div id='notes'></div>
  <script>
    // The `html` key maps to the .html() method -> innerHTML execution.
    $('<div>', { 'class': 'note', html: '#{query}' }).appendTo('#notes');
  </script>
  </body></html>"
end
