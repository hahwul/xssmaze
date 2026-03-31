def load_comment_injection_xss
  # Level 1: Reflected inside HTML comment <!-- QUERY --> - close comment with --> then inject HTML
  Xssmaze.push("commentinj-level1", "/commentinj/level1/?query=a", "reflected inside HTML comment")
  maze_get "/commentinj/level1/" do |env|
    query = env.params.query["query"]
    "<html><body><!-- #{query} --><p>Safe content</p></body></html>"
  end

  # Level 2: Reflected inside /* QUERY */ in a script tag - close comment with */ then </script> then inject
  Xssmaze.push("commentinj-level2", "/commentinj/level2/?query=a", "reflected inside JS block comment in script tag")
  maze_get "/commentinj/level2/" do |env|
    query = env.params.query["query"]
    "<html><body><script>/* #{query} */var x=1;</script><p>Safe content</p></body></html>"
  end

  # Level 3: Reflected inside // QUERY single-line JS comment in script - newline then </script> then inject
  Xssmaze.push("commentinj-level3", "/commentinj/level3/?query=a", "reflected inside JS single-line comment in script tag")
  maze_get "/commentinj/level3/" do |env|
    query = env.params.query["query"]
    "<html><body><script>// #{query}\nvar x=1;</script><p>Safe content</p></body></html>"
  end

  # Level 4: Reflected inside conditional comment <!--[if IE]>QUERY<![endif]--> - close with <![endif]--> then inject
  Xssmaze.push("commentinj-level4", "/commentinj/level4/?query=a", "reflected inside conditional comment")
  maze_get "/commentinj/level4/" do |env|
    query = env.params.query["query"]
    "<html><body><!--[if IE]>#{query}<![endif]--><p>Safe content</p></body></html>"
  end

  # Level 5: Reflected inside HTML comment but --> is stripped (single pass) - use --!> which also closes comments
  Xssmaze.push("commentinj-level5", "/commentinj/level5/?query=a", "reflected inside HTML comment with --> stripped (use --!> to close)")
  maze_get "/commentinj/level5/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("-->", "")
    "<html><body><!-- #{filtered} --><p>Safe content</p></body></html>"
  end

  # Level 6: Reflected inside JS block comment in script tag (both * and / allowed) - close comment then close script
  Xssmaze.push("commentinj-level6", "/commentinj/level6/?query=a", "reflected inside JS block comment - close comment and script tag")
  maze_get "/commentinj/level6/" do |env|
    query = env.params.query["query"]
    "<html><body><script>/* #{query} */</script><p>Safe content</p></body></html>"
  end
end
