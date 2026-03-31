def load_context_escape_v2_xss
  # Level 1: Reflection inside an HTML comment <!-- QUERY -->
  # Bypass: close the comment with --> then inject HTML
  # e.g. --><script>alert(1)</script><!-- or --><img src=x onerror=alert(1)>
  Xssmaze.push("ctxv2-level1", "/ctxv2/level1/?query=a", "reflection inside HTML comment (close with -->)")
  maze_get "/ctxv2/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><!-- Search query: #{query} --><div>Welcome</div></body></html>"
  end

  # Level 2: Reflection inside a <textarea> tag
  # Content inside <textarea> is treated as raw text by the HTML parser.
  # Bypass: close the textarea first with </textarea> then inject HTML
  # e.g. </textarea><script>alert(1)</script>
  Xssmaze.push("ctxv2-level2", "/ctxv2/level2/?query=a", "reflection inside textarea tag (close tag escape)")
  maze_get "/ctxv2/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><h2>Edit your message:</h2><textarea name=\"message\" rows=\"5\" cols=\"40\">#{query}</textarea></body></html>"
  end

  # Level 3: Reflection inside a <title> tag
  # Content inside <title> is treated as raw text by the HTML parser.
  # Bypass: close the title first with </title> then inject HTML
  # e.g. </title><script>alert(1)</script>
  Xssmaze.push("ctxv2-level3", "/ctxv2/level3/?query=a", "reflection inside title tag (close tag escape)")
  maze_get "/ctxv2/level3/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Search: #{query}</title></head><body><h2>Results</h2><p>Searching...</p></body></html>"
  end

  # Level 4: Reflection inside a <style> tag (CSS context)
  # Content inside <style> is treated as raw text by the HTML parser.
  # Bypass: close the style tag with </style> then inject HTML
  # e.g. </style><script>alert(1)</script>
  Xssmaze.push("ctxv2-level4", "/ctxv2/level4/?query=a", "reflection inside style tag (close tag escape)")
  maze_get "/ctxv2/level4/" do |env|
    query = env.params.query["query"]

    "<html><head><style>.user-theme { color: #{query}; }</style></head><body><div class=\"user-theme\">Styled content</div></body></html>"
  end

  # Level 5: Reflection inside a <noscript> tag
  # Content inside <noscript> is parsed as raw text when scripting is enabled.
  # Bypass: close the noscript tag with </noscript> then inject HTML
  # e.g. </noscript><script>alert(1)</script>
  Xssmaze.push("ctxv2-level5", "/ctxv2/level5/?query=a", "reflection inside noscript tag (close tag escape)")
  maze_get "/ctxv2/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><noscript>JavaScript required. Your search: #{query}</noscript><div>Main content</div></body></html>"
  end

  # Level 6: Reflection inside an <iframe srcdoc="QUERY"> attribute
  # The srcdoc attribute value is HTML-parsed by the browser, so HTML entities work inside it.
  # The server encodes < and > to &lt; &gt; in the srcdoc value to prevent attribute breakout,
  # but does NOT encode & — so HTML entity payloads like &#60;script&#62;alert(1)&#60;/script&#62;
  # survive encoding and get decoded when the browser parses the srcdoc HTML.
  # Bypass: use HTML entities e.g. &lt;img src=x onerror=alert(1)&gt;
  # which the server leaves as-is (& not encoded), and the browser decodes inside srcdoc.
  Xssmaze.push("ctxv2-level6", "/ctxv2/level6/?query=a", "reflection in iframe srcdoc (HTML entity injection via unescaped &)")
  maze_get "/ctxv2/level6/" do |env|
    query = env.params.query["query"]
    # Encode < and > to prevent direct attribute breakout, but leave & intact
    # This means pre-encoded HTML entities in the input survive and get rendered in srcdoc
    filtered = query.gsub("<", "&lt;").gsub(">", "&gt;")

    "<html><body><h2>Preview</h2><iframe srcdoc=\"#{filtered}\" width=\"500\" height=\"300\"></iframe></body></html>"
  end
end
