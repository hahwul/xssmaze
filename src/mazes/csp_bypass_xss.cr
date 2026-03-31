def load_csp_bypass_xss
  # Level 1: CSP script-src 'unsafe-inline' - raw reflection, scripts execute because of unsafe-inline
  Xssmaze.push("cspbypass-level1", "/cspbypass/level1/?query=a", "CSP unsafe-inline allows raw script injection")
  maze_get "/cspbypass/level1/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-inline'"

    "<html><head></head><body>
    <h1>CSP Bypass Level 1</h1>
    <p>Search results for: #{query}</p>
    </body></html>"
  end

  # Level 2: CSP default-src 'self' but query reflected inside existing <script nonce="..."> block as a string - break out of string context
  Xssmaze.push("cspbypass-level2", "/cspbypass/level2/?query=a", "CSP nonce script with reflection in JS string context")
  maze_get "/cspbypass/level2/" do |env|
    query = env.params.query["query"]
    nonce = "r4nd0mN0nc3"
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'nonce-#{nonce}'"

    "<html><head></head><body>
    <h1>CSP Bypass Level 2</h1>
    <script nonce=\"#{nonce}\">
      var greeting = \"Hello #{query}\";
      document.write(greeting);
    </script>
    </body></html>"
  end

  # Level 3: CSP with script-src 'self' 'unsafe-eval' and reflection in JS string that gets eval'd - close script tag, inject HTML
  Xssmaze.push("cspbypass-level3", "/cspbypass/level3/?query=a", "CSP unsafe-eval with reflection in eval'd JS string")
  maze_get "/cspbypass/level3/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' 'unsafe-eval'"

    "<html><head></head><body>
    <h1>CSP Bypass Level 3</h1>
    <script>
      var data = \"#{query}\";
      eval('document.write(data)');
    </script>
    </body></html>"
  end

  # Level 4: No CSP header at all, but <script> tag stripped (single pass) - use nested tag trick or <img> tag
  Xssmaze.push("cspbypass-level4", "/cspbypass/level4/?query=a", "no CSP but single-pass script tag strip")
  maze_get "/cspbypass/level4/" do |env|
    query = env.params.query["query"]
    # Single-pass removal of <script> and </script> tags
    filtered = query.gsub(/<\/?script[^>]*>/i, "")

    "<html><head></head><body>
    <h1>CSP Bypass Level 4</h1>
    <p>Output: #{filtered}</p>
    </body></html>"
  end

  # Level 5: CSP script-src 'unsafe-inline' with query reflected in <script> block, only 'alert' keyword is stripped
  Xssmaze.push("cspbypass-level5", "/cspbypass/level5/?query=a", "CSP unsafe-inline with alert keyword stripped")
  maze_get "/cspbypass/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/alert/i, "")
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'unsafe-inline'"

    "<html><head></head><body>
    <h1>CSP Bypass Level 5</h1>
    <script>
      var msg = \"#{filtered}\";
    </script>
    </body></html>"
  end

  # Level 6: CSP header present but misconfigured: script-src * (allows everything) - raw reflection
  Xssmaze.push("cspbypass-level6", "/cspbypass/level6/?query=a", "CSP misconfigured with script-src * allowing all scripts")
  maze_get "/cspbypass/level6/" do |env|
    query = env.params.query["query"]
    env.response.headers["Content-Security-Policy"] = "default-src 'self'; script-src *"

    "<html><head></head><body>
    <h1>CSP Bypass Level 6</h1>
    <div>Welcome: #{query}</div>
    </body></html>"
  end
end
