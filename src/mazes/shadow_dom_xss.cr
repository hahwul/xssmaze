Xssmaze.push("shadow-dom-level1", "/shadow-dom/level1/?query=a", "open shadow root + innerHTML",
  vuln: "dom", sources: ["server-reflected"], sinks: ["attachShadow.innerHTML"], delivery: ["query"])
maze_get "/shadow-dom/level1/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Shadow DOM Level 1</h1>
  <div id='host'></div>
  <script>
    var host = document.getElementById('host');
    var shadow = host.attachShadow({mode: 'open'});
    shadow.innerHTML = '<div>#{query}</div>';
  </script>
  </body></html>"
end

Xssmaze.push("shadow-dom-level2", "/shadow-dom/level2/?query=a", "closed shadow root + innerHTML via getter",
  vuln: "dom", sources: ["server-reflected"], sinks: ["attachShadow.innerHTML"], delivery: ["query"], note: "closed shadow root: not inspectable from outside, but the injection still executes")
maze_get "/shadow-dom/level2/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Shadow DOM Level 2</h1>
  <div id='host'></div>
  <script>
    var host = document.getElementById('host');
    var shadow = host.attachShadow({mode: 'closed'});
    // Closed shadow root: external tools can't inspect, but injection still works
    shadow.innerHTML = '<div>#{query}</div>';
  </script>
  </body></html>"
end

Xssmaze.push("shadow-dom-level3", "/shadow-dom/level3/?query=a", "shadow DOM + slot injection",
  vuln: "reflected-html", delivery: ["query"], note: "light-DOM reflection that is then slotted into the shadow root")
maze_get "/shadow-dom/level3/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Shadow DOM Level 3</h1>
  <div id='host'>#{query}</div>
  <script>
    var host = document.getElementById('host');
    var shadow = host.attachShadow({mode: 'open'});
    shadow.innerHTML = '<style>:host { display: block; }</style><slot></slot>';
    // Slotted content from light DOM is rendered inside shadow DOM
  </script>
  </body></html>"
end

Xssmaze.push("shadow-dom-level4", "/shadow-dom/level4/?query=a", "shadow DOM + declarative shadow DOM",
  vuln: "reflected-html", delivery: ["query"], note: "declarative shadow DOM (<template shadowrootmode>); modern browsers only")
maze_get "/shadow-dom/level4/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Shadow DOM Level 4</h1>
  <div id='host'>
    <template shadowrootmode='open'>
      <div>#{query}</div>
    </template>
  </div>
  </body></html>"
end

Xssmaze.push("shadow-dom-level5", "/shadow-dom/level5/?query=a", "shadow DOM + adoptedStyleSheets CSS injection",
  vuln: "reflected-js", sinks: ["adoptedStyleSheets"], delivery: ["query"], note: "the value is reflected raw into a single-quoted JS string argument, so it never has to be valid CSS: close the string and run code with ');alert(1)//")
maze_get "/shadow-dom/level5/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Shadow DOM Level 5</h1>
  <div id='host'></div>
  <script>
    var host = document.getElementById('host');
    var shadow = host.attachShadow({mode: 'open'});
    shadow.innerHTML = '<div id=\"inner\">Content</div>';
    try {
      var sheet = new CSSStyleSheet();
      sheet.replaceSync('#{query}');
      shadow.adoptedStyleSheets = [sheet];
    } catch(e) {}
  </script>
  </body></html>"
end
