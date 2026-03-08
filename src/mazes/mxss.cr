def load_mxss
  Xssmaze.push("mxss-level1", "/mxss/level1/?query=a", "mutation XSS via innerHTML round-trip")
  maze_get "/mxss/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>mXSS Level 1</h1>
    <div id='output'></div>
    <script>
      var sanitizer = document.createElement('div');
      sanitizer.innerHTML = '#{query}';
      // Round-trip: serialize and re-parse (mutation can occur)
      document.getElementById('output').innerHTML = sanitizer.innerHTML;
    </script>
    </body></html>"
  end

  Xssmaze.push("mxss-level2", "/mxss/level2/?query=a", "mutation XSS via DOMParser + innerHTML re-serialize")
  maze_get "/mxss/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>mXSS Level 2</h1>
    <div id='output'></div>
    <script>
      var parser = new DOMParser();
      var doc = parser.parseFromString('#{query}', 'text/html');
      // Re-serialize from parsed DOM (mutations may occur between parse contexts)
      var serialized = doc.body.innerHTML;
      document.getElementById('output').innerHTML = serialized;
    </script>
    </body></html>"
  end

  Xssmaze.push("mxss-level3", "/mxss/level3/?query=a", "mutation XSS via template + namespace confusion")
  maze_get "/mxss/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>mXSS Level 3</h1>
    <div id='output'></div>
    <script>
      var template = document.createElement('template');
      template.innerHTML = '#{query}';
      // Clone from template context into document context
      var clone = template.content.cloneNode(true);
      var wrapper = document.createElement('div');
      wrapper.appendChild(clone);
      // Re-serialize and inject (namespace confusion between template and document)
      document.getElementById('output').innerHTML = wrapper.innerHTML;
    </script>
    </body></html>"
  end

  Xssmaze.push("mxss-level4", "/mxss/level4/?query=a", "mutation XSS via SVG foreignObject namespace switch")
  maze_get "/mxss/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>mXSS Level 4</h1>
    <div id='output'></div>
    <script>
      // SVG namespace parsing can cause mutation when re-serialized to HTML context
      var svgWrapper = '<svg><foreignObject>#{query}</foreignObject></svg>';
      var parser = new DOMParser();
      var doc = parser.parseFromString(svgWrapper, 'text/html');
      var svgEl = doc.querySelector('svg');
      if (svgEl) {
        document.getElementById('output').innerHTML = svgEl.innerHTML;
      }
    </script>
    </body></html>"
  end

  Xssmaze.push("mxss-level5", "/mxss/level5/?query=a", "mutation XSS via math/style element parsing differential")
  maze_get "/mxss/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>mXSS Level 5</h1>
    <div id='output'></div>
    <script>
      // Math namespace + style element can cause parsing differentials
      var input = '<math><style>#{query}</style></math>';
      var sanitizer = document.createElement('div');
      sanitizer.innerHTML = input;
      // The style content may be interpreted differently after re-serialization
      document.getElementById('output').innerHTML = sanitizer.innerHTML;
    </script>
    </body></html>"
  end
end
