def load_dom_context_xss
  # Level 1: Query reflected inside <div id="output">QUERY</div> with no filtering - basic HTML injection
  Xssmaze.push("domctx-level1", "/domctx/level1/?query=a", "reflection in div body with no filtering")
  maze_get "/domctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
    <h1>DOM Context Level 1</h1>
    <div id=\"output\">#{query}</div>
    </body></html>"
  end

  # Level 2: Query reflected in document.write("QUERY") inside script - close script tag and inject
  Xssmaze.push("domctx-level2", "/domctx/level2/?query=a", "reflection in document.write JS string")
  maze_get "/domctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
    <h1>DOM Context Level 2</h1>
    <script>
      document.write(\"#{query}\");
    </script>
    </body></html>"
  end

  # Level 3: Query reflected in .innerHTML = "QUERY" inside script - close script tag and inject
  Xssmaze.push("domctx-level3", "/domctx/level3/?query=a", "reflection in innerHTML assignment JS string")
  maze_get "/domctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
    <h1>DOM Context Level 3</h1>
    <div id=\"target\"></div>
    <script>
      document.getElementById('target').innerHTML = \"#{query}\";
    </script>
    </body></html>"
  end

  # Level 4: Query reflected as JSON value in <script>var config = {"name":"QUERY"};</script> - close script tag and inject
  Xssmaze.push("domctx-level4", "/domctx/level4/?query=a", "reflection in JSON object inside script tag")
  maze_get "/domctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
    <h1>DOM Context Level 4</h1>
    <script>var config = {\"name\":\"#{query}\"};</script>
    </body></html>"
  end

  # Level 5: Query URL-decoded then reflected in <div>QUERY</div> (server does URI.decode) - send URL-encoded payload
  Xssmaze.push("domctx-level5", "/domctx/level5/?query=a", "server URL-decodes then reflects in div body")
  maze_get "/domctx/level5/" do |env|
    query = env.params.query["query"]
    decoded = URI.decode(query)

    "<html><head></head><body>
    <h1>DOM Context Level 5</h1>
    <div>#{decoded}</div>
    </body></html>"
  end

  # Level 6: Query reflected in eval("QUERY") inside script - close script tag and inject
  Xssmaze.push("domctx-level6", "/domctx/level6/?query=a", "reflection in eval string inside script tag")
  maze_get "/domctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
    <h1>DOM Context Level 6</h1>
    <script>
      eval(\"#{query}\");
    </script>
    </body></html>"
  end
end
