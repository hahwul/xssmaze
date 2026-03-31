def load_template_injection_xss
  # Level 1: Reflection inside JS template literal ${...} in a script tag
  # Exploit: Close the template literal expression and inject, e.g. };alert(1)//
  # Or break out of script entirely: </script><img src=x onerror=alert(1)>
  Xssmaze.push("tplinject-level1", "/tplinject/level1/?query=a", "reflection inside JS template literal interpolation")
  maze_get "/tplinject/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Template Injection XSS Level 1</h1>
    <script>
      var greeting = `Hello ${\"#{query}\"}!`;
      document.write(greeting);
    </script>
    </body></html>"
  end

  # Level 2: Reflection inside an HTML <template> element that gets cloned and inserted via innerHTML
  # The template content is inert until cloned, but innerHTML assignment makes it live
  # Exploit: <img src=x onerror=alert(1)> or <script>alert(1)</script>
  Xssmaze.push("tplinject-level2", "/tplinject/level2/?query=a", "HTML template element cloned to innerHTML")
  maze_get "/tplinject/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Template Injection XSS Level 2</h1>
    <div id=\"output\"></div>
    <template id=\"tpl\"><div>Welcome, #{query}</div></template>
    <script>
      var tpl = document.getElementById('tpl');
      document.getElementById('output').innerHTML = tpl.innerHTML;
    </script>
    </body></html>"
  end

  # Level 3: Reflection in a JS variable that's passed to innerHTML via indirect DOM sink
  # Exploit: Break out of JS string with '</script><img src=x onerror=alert(1)>'
  # Or inject into the JS string which flows to innerHTML: <img src=x onerror=alert(1)>
  Xssmaze.push("tplinject-level3", "/tplinject/level3/?query=a", "JS string assigned to innerHTML (indirect DOM sink)")
  maze_get "/tplinject/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Template Injection XSS Level 3</h1>
    <div id=\"content\"></div>
    <script>
      var userData = '#{query}';
      var container = document.getElementById('content');
      container.innerHTML = '<p>Search result: ' + userData + '</p>';
    </script>
    </body></html>"
  end

  # Level 4: Reflection inside a script type="text/template" block, rendered via innerHTML
  # The browser ignores script type="text/template" but JS reads and renders it
  # Exploit: <img src=x onerror=alert(1)> gets stored in the template and rendered to innerHTML
  Xssmaze.push("tplinject-level4", "/tplinject/level4/?query=a", "script type=text/template rendered via innerHTML")
  maze_get "/tplinject/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Template Injection XSS Level 4</h1>
    <div id=\"render-target\"></div>
    <script type=\"text/template\" id=\"user-template\">
      <div class=\"card\">
        <h2>User Profile</h2>
        <p>Name: #{query}</p>
      </div>
    </script>
    <script>
      var tmpl = document.getElementById('user-template').innerHTML;
      document.getElementById('render-target').innerHTML = tmpl;
    </script>
    </body></html>"
  end

  # Level 5: Server-side double render - first pass resolves {{query}}, second inserts raw HTML
  # The server replaces {{query}} with input, then the result is placed directly in the page
  # Exploit: Payload like <img src=x onerror=alert(1)> is placed via template substitution
  Xssmaze.push("tplinject-level5", "/tplinject/level5/?query=a", "server-side double template render")
  maze_get "/tplinject/level5/" do |env|
    query = env.params.query["query"]

    # First pass: build template with placeholder
    template = "<div class='wrapper'>{{content}}</div>"
    # Second pass: replace placeholder with the user-controlled query
    inner = "<span class='label'>Result:</span> {{user}}"
    inner = inner.gsub("{{user}}", query)
    output = template.gsub("{{content}}", inner)

    "<html><body>
    <h1>Template Injection XSS Level 5</h1>
    #{output}
    </body></html>"
  end

  # Level 6: Reflection inside a data-attribute that JavaScript reads and writes to innerHTML
  # Exploit: Break out of the attribute with "> and inject HTML: "><img src=x onerror=alert(1)>
  # Or the data value itself flows to innerHTML: <img src=x onerror=alert(1)>
  Xssmaze.push("tplinject-level6", "/tplinject/level6/?query=a", "data-attribute read by JS and written to innerHTML")
  maze_get "/tplinject/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Template Injection XSS Level 6</h1>
    <div id=\"source\" data-user=\"#{query}\" style=\"display:none\"></div>
    <div id=\"sink\"></div>
    <script>
      var src = document.getElementById('source');
      var val = src.getAttribute('data-user');
      document.getElementById('sink').innerHTML = '<p>Hello, ' + val + '</p>';
    </script>
    </body></html>"
  end
end
