def load_encoding_mix_xss
  # Level 1: UTF-7 Content-Type allowing +ADw-script+AD4- injection
  # Exploit: +ADw-script+AD4-alert(1)+ADw-/script+AD4- which is UTF-7 for <script>alert(1)</script>
  # Or just use raw <script>alert(1)</script> since the body is not encoded
  Xssmaze.push("encmix-level1", "/encmix/level1/?query=a", "UTF-7 charset in Content-Type with raw reflection")
  maze_get "/encmix/level1/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html; charset=utf-7"

    "<html><body>
    <h1>Encoding Mix XSS Level 1</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 2: HTML entity encodes < > but NOT & — allowing double-entity bypass
  # The server encodes < to &lt; and > to &gt;, but & is left raw
  # Exploit: &#x3c;script&#x3e;alert(1)&#x3c;/script&#x3e; — server does not re-encode the &
  # so the HTML entities are preserved and the browser decodes them to <script>alert(1)</script>
  Xssmaze.push("encmix-level2", "/encmix/level2/?query=a", "HTML entity encode < > but not & (double-entity bypass)")
  maze_get "/encmix/level2/" do |env|
    query = env.params.query["query"]
    # Only encode literal < and > but leave & untouched
    filtered = query.gsub("<", "&lt;").gsub(">", "&gt;")

    "<html><body>
    <h1>Encoding Mix XSS Level 2</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 3: Backslash escaping in JS string but no unicode escape filtering
  # The server escapes ' with \' but does not filter \uXXXX sequences
  # Exploit: \u003cimg src=x onerror=alert(1)\u003e — JS interprets unicode escapes in strings
  # Or break out with: </script><img src=x onerror=alert(1)>
  Xssmaze.push("encmix-level3", "/encmix/level3/?query=a", "JS string with backslash escape but no unicode filtering")
  maze_get "/encmix/level3/" do |env|
    query = env.params.query["query"]
    # Escape single quotes and backslashes for the JS string
    escaped = query.gsub("\\", "\\\\").gsub("'", "\\'")

    "<html><body>
    <h1>Encoding Mix XSS Level 3</h1>
    <div id=\"output\"></div>
    <script>
      var data = '#{escaped}';
      document.getElementById('output').innerHTML = data;
    </script>
    </body></html>"
  end

  # Level 4: JSON value reflected with Content-Type text/html
  # The server builds a JSON response but serves it as text/html
  # Exploit: Break out of JSON string value and inject HTML tags
  # e.g. </script><img src=x onerror=alert(1)> or just raw HTML in the JSON context
  Xssmaze.push("encmix-level4", "/encmix/level4/?query=a", "JSON context served as text/html")
  maze_get "/encmix/level4/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html"

    "<html><body>
    <h1>Encoding Mix XSS Level 4</h1>
    <script>
      var config = {\"search\": \"#{query}\", \"page\": 1};
    </script>
    <div>Search results for: <span id=\"q\"></span></div>
    <script>
      document.getElementById('q').innerHTML = config.search;
    </script>
    </body></html>"
  end

  # Level 5: URL decode + HTML entity encode, but only first occurrence is encoded
  # The server URL-decodes, then HTML-entity-encodes only the first < and first >
  # Second occurrence of < > remains raw
  # Exploit: Use two sets of angle brackets — first pair gets encoded, second pair is raw
  # e.g. <x><img src=x onerror=alert(1)>
  Xssmaze.push("encmix-level5", "/encmix/level5/?query=a", "HTML encode only first < and > (second reflection raw)")
  maze_get "/encmix/level5/" do |env|
    query = env.params.query["query"]

    begin
      decoded = URI.decode(query)
    rescue
      decoded = query
    end

    # Only encode the first occurrence of < and >
    filtered = decoded.sub("<", "&lt;").sub(">", "&gt;")

    "<html><body>
    <h1>Encoding Mix XSS Level 5</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 6: ISO-8859-1 charset with raw reflection
  # Serves content with charset=iso-8859-1 and reflects input without encoding
  # This can cause character interpretation differences with high-byte characters
  # Exploit: Standard XSS payloads work since there is no filtering: <script>alert(1)</script>
  Xssmaze.push("encmix-level6", "/encmix/level6/?query=a", "ISO-8859-1 charset with raw reflection")
  maze_get "/encmix/level6/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html; charset=iso-8859-1"

    "<html>
    <head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"></head>
    <body>
    <h1>Encoding Mix XSS Level 6</h1>
    <div>#{query}</div>
    </body></html>"
  end
end
