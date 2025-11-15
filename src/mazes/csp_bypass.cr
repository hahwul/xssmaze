def load_csp_bypass
  Xssmaze.push("csp-bypass-level1", "/csp/level1/?query=a", "CSP bypass with unsafe-inline")
  get "/csp/level1/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-inline'"
    
    "<html><head></head><body>
    <h1>CSP Level 1</h1>
    <div>User input: #{query}</div>
    </body></html>"
  end
  get "/csp/level1" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-inline'"
    
    "<html><head></head><body>
    <h1>CSP Level 1</h1>
    <div>User input: #{query}</div>
    </body></html>"
  end

  Xssmaze.push("csp-bypass-level2", "/csp/level2/?query=a", "CSP bypass with nonce")
  get "/csp/level2/" do |env|
    query = env.params.query["query"]
    nonce = "abc123"
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'nonce-#{nonce}'"
    
    "<html><head></head><body>
    <h1>CSP Level 2</h1>
    <script nonce='#{nonce}'>
      document.write('#{query}')
    </script>
    </body></html>"
  end
  get "/csp/level2" do |env|
    query = env.params.query["query"]
    nonce = "abc123"
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'nonce-#{nonce}'"
    
    "<html><head></head><body>
    <h1>CSP Level 2</h1>
    <script nonce='#{nonce}'>
      document.write('#{query}')
    </script>
    </body></html>"
  end

  Xssmaze.push("csp-bypass-level3", "/csp/level3/?query=a", "CSP bypass with eval and unsafe-eval")
  get "/csp/level3/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-eval'"
    
    "<html><head></head><body>
    <h1>CSP Level 3</h1>
    <script>
      eval('var userInput = \"#{query}\"; document.write(userInput);')
    </script>
    </body></html>"
  end
  get "/csp/level3" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-eval'"
    
    "<html><head></head><body>
    <h1>CSP Level 3</h1>
    <script>
      eval('var userInput = \"#{query}\"; document.write(userInput);')
    </script>
    </body></html>"
  end

  Xssmaze.push("csp-bypass-level4", "/csp/level4/?query=a", "CSP bypass with strict policy (data: URI)")
  get "/csp/level4/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'"
    
    "<html><head></head><body>
    <h1>CSP Level 4</h1>
    <iframe src=\"data:text/html,<script>parent.postMessage('#{query}','*')</script>\"></iframe>
    <script>
      window.addEventListener('message', function(e) {
        document.body.innerHTML += '<div>' + e.data + '</div>';
      });
    </script>
    </body></html>"
  end
  get "/csp/level4" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'"
    
    "<html><head></head><body>
    <h1>CSP Level 4</h1>
    <iframe src=\"data:text/html,<script>parent.postMessage('#{query}','*')</script>\"></iframe>
    <script>
      window.addEventListener('message', function(e) {
        document.body.innerHTML += '<div>' + e.data + '</div>';
      });
    </script>
    </body></html>"
  end

  Xssmaze.push("csp-bypass-level5", "/csp/level5/?query=a", "CSP bypass with meta tag injection")
  get "/csp/level5/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <meta http-equiv='Content-Security-Policy' content=\"default-src 'self'; script-src 'unsafe-inline'\">
    </head><body>
    <h1>CSP Level 5</h1>
    #{query}
    </body></html>"
  end
  get "/csp/level5" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <meta http-equiv='Content-Security-Policy' content=\"default-src 'self'; script-src 'unsafe-inline'\">
    </head><body>
    <h1>CSP Level 5</h1>
    #{query}
    </body></html>"
  end
end