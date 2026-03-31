def load_context_escape_xss
  # Level 1: Double-quoted JS string, single quote allowed, </script> allowed
  # Break out with: </script><img src=x onerror=alert(1)>
  # Or: ";alert(1);//
  Xssmaze.push("ctxescape-level1", "/ctxescape/level1/?query=a", "double-quoted JS, single quote + close-script allowed")
  maze_get "/ctxescape/level1/" do |env|
    query = env.params.query["query"]
    escaped = query.gsub("\"", "\\\"")

    "<script>var x = \"#{escaped}\";</script>"
  end

  # Level 2: Template literal (backtick) JS context
  # Input inside `${...}` is safe, but closing backtick allows injection
  Xssmaze.push("ctxescape-level2", "/ctxescape/level2/?query=a", "JS template literal context")
  maze_get "/ctxescape/level2/" do |env|
    query = env.params.query["query"]

    "<script>var x = `Hello #{query}`;</script>"
  end

  # Level 3: CSS url() function context
  Xssmaze.push("ctxescape-level3", "/ctxescape/level3/?query=a", "CSS url() function injection")
  maze_get "/ctxescape/level3/" do |env|
    query = env.params.query["query"]

    "<style>.bg { background: url('#{query}'); }</style><div class=\"bg\">Content</div>"
  end

  # Level 4: HTML comment context, -- not stripped
  Xssmaze.push("ctxescape-level4", "/ctxescape/level4/?query=a", "HTML comment context (-- allowed)")
  maze_get "/ctxescape/level4/" do |env|
    query = env.params.query["query"]

    "<!-- User query: #{query} --><div>Results</div>"
  end

  # Level 5: Reflection after = in unquoted attribute, space creates new attribute
  Xssmaze.push("ctxescape-level5", "/ctxescape/level5/?query=a", "unquoted attribute value (space breaks out)")
  maze_get "/ctxescape/level5/" do |env|
    query = Filters.strip_angles(env.params.query["query"])

    "<input value=#{query} type=text>"
  end

  # Level 6: Inside JS block comment /* ... */
  Xssmaze.push("ctxescape-level6", "/ctxescape/level6/?query=a", "JS block comment context")
  maze_get "/ctxescape/level6/" do |env|
    query = env.params.query["query"]

    "<script>/* User: #{query} */ var safe = true;</script>"
  end

  # Level 7: JS single-line comment // (newline injection)
  Xssmaze.push("ctxescape-level7", "/ctxescape/level7/?query=a", "JS line comment context (newline escape)")
  maze_get "/ctxescape/level7/" do |env|
    query = env.params.query["query"]

    "<script>// Search: #{query}\nvar safe = true;</script>"
  end

  # Level 8: Reflection inside <pre> tag (HTML context, but encoded)
  Xssmaze.push("ctxescape-level8", "/ctxescape/level8/?query=a", "pre tag body reflection (raw HTML)")
  maze_get "/ctxescape/level8/" do |env|
    query = env.params.query["query"]

    "<html><body><pre>#{query}</pre></body></html>"
  end
end
