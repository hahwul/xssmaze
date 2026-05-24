Xssmaze.push("import-map-level1", "/import-map/level1/?query=a", "import map injection via script type=importmap with dynamic import().then()")
maze_get "/import-map/level1/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 1</h1>
  <p>Application loads a whitelisted module via import map</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"whitelisted-module\": \"#{query}\"
    }
  }
  </script>
  <script type='module'>
    import('whitelisted-module').then(module => {
      document.getElementById('output').textContent = 'Module loaded successfully';
    }).catch(err => {
      document.getElementById('output').textContent = 'Error: ' + err.message;
    });
  </script>
  </body></html>"
end

Xssmaze.push("import-map-level2", "/import-map/level2/?query=a", "import map injection in single-quoted context with module hijacking")
maze_get "/import-map/level2/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 2</h1>
  <p>Application dynamically creates import map with user input in single-quoted context</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"trusted-lib\": \"https://cdn.example.com/lib.js\"
    }
  }
  </script>
  <script>
    var userConfig = '#{query}';
    var importMap = document.createElement('script');
    importMap.type = 'importmap';
    importMap.textContent = JSON.stringify({
      imports: { 'user-module': userConfig }
    });
    document.head.appendChild(importMap);

    setTimeout(() => {
      import('user-module').then(module => {
        document.getElementById('output').textContent = 'User module loaded';
      }).catch(err => {
        document.getElementById('output').textContent = 'Error: ' + err.message;
      });
    }, 100);
  </script>
  </body></html>"
end

Xssmaze.push("import-map-level3", "/import-map/level3/?query=a", "import map with double-quoted JSON property and data: URL hijacking")
maze_get "/import-map/level3/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 3</h1>
  <p>Import map uses double-quoted property, attacker can hijack with data: URL</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"analytics\": \"#{query}\"
    }
  }
  </script>
  <script type='module'>
    import('analytics').then(module => {
      document.getElementById('output').textContent = 'Analytics module loaded';
    }).catch(err => {
      document.getElementById('output').textContent = 'Error: ' + err.message;
    });
  </script>
  </body></html>"
end

Xssmaze.push("import-map-level4", "/import-map/level4/?query=a", "import map module overwrite with attacker-controlled domain")
maze_get "/import-map/level4/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 4</h1>
  <p>Application uses import map to load trusted modules, but path is user-controlled</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"payment-processor\": \"#{query}\",
      \"auth-lib\": \"https://cdn.example.com/auth.js\"
    }
  }
  </script>
  <script type='module'>
    // Simulate legitimate app code that imports the payment processor
    import('payment-processor').then(processor => {
      document.getElementById('output').textContent = 'Payment processor loaded: processing transaction...';
    }).catch(err => {
      document.getElementById('output').textContent = 'Error: ' + err.message;
    });
  </script>
  </body></html>"
end

Xssmaze.push("import-map-level5", "/import-map/level5/?query=a", "scoped import map with bare module specifier hijacking")
maze_get "/import-map/level5/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 5</h1>
  <p>Application uses scoped packages with import map, user input in scope resolution</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"@company/core\": \"https://cdn.example.com/core.js\",
      \"@user/config\": \"#{query}\"
    }
  }
  </script>
  <script type='module'>
    Promise.all([
      import('@company/core'),
      import('@user/config')
    ]).then(([core, config]) => {
      document.getElementById('output').textContent = 'All modules loaded';
    }).catch(err => {
      document.getElementById('output').textContent = 'Error: ' + err.message;
    });
  </script>
  </body></html>"
end

Xssmaze.push("import-map-level6", "/import-map/level6/?query=a", "import map with trailing slash scope and path manipulation")
maze_get "/import-map/level6/" do |env|
  query = env.params.query["query"]

  "<html><body>
  <h1>Import Map Level 6</h1>
  <p>Import map uses scopes with trailing slashes, user input affects path resolution</p>
  <div id='output'></div>
  <script type='importmap'>
  {
    \"imports\": {
      \"lodash/\": \"https://cdn.example.com/lodash/\"
    },
    \"scopes\": {
      \"/app/\": {
        \"custom-util\": \"#{query}\"
      }
    }
  }
  </script>
  <script type='module'>
    import('custom-util').then(util => {
      document.getElementById('output').textContent = 'Custom utility loaded';
    }).catch(err => {
      document.getElementById('output').textContent = 'Error: ' + err.message;
    });
  </script>
  </body></html>"
end
