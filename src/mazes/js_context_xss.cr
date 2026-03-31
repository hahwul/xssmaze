def load_js_context_xss
  # Level 1: Reflection in JS variable assignment var x = "QUERY";
  # Bypass: close script tag and inject HTML
  # e.g. </script><script>alert(1)</script>
  Xssmaze.push("jsctx-level1", "/jsctx/level1/?query=a", "reflection in JS variable assignment (double-quoted string)")
  maze_get "/jsctx/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var x = \"#{query}\";</script></body></html>"
  end

  # Level 2: Reflection in JS object key {QUERY: "value"}
  # Bypass: close script tag and inject HTML
  # e.g. </script><script>alert(1)</script>
  Xssmaze.push("jsctx-level2", "/jsctx/level2/?query=a", "reflection in JS object key")
  maze_get "/jsctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var obj = {#{query}: \"value\"};</script></body></html>"
  end

  # Level 3: Reflection in JS array element ["a", "QUERY", "b"]
  # Bypass: close script tag and inject HTML
  # e.g. </script><script>alert(1)</script>
  Xssmaze.push("jsctx-level3", "/jsctx/level3/?query=a", "reflection in JS array element (double-quoted)")
  maze_get "/jsctx/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var arr = [\"a\", \"#{query}\", \"b\"];</script></body></html>"
  end

  # Level 4: Reflection in JS function argument func("QUERY")
  # Bypass: close script tag and inject HTML
  # e.g. </script><script>alert(1)</script>
  Xssmaze.push("jsctx-level4", "/jsctx/level4/?query=a", "reflection in JS function argument (double-quoted)")
  maze_get "/jsctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><script>function process(d){return d;} process(\"#{query}\");</script></body></html>"
  end

  # Level 5: Reflection in JS regex /QUERY/g
  # Bypass: close script tag and inject HTML
  # e.g. </script><script>alert(1)</script>
  Xssmaze.push("jsctx-level5", "/jsctx/level5/?query=a", "reflection in JS regex literal")
  maze_get "/jsctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><script>var pattern = /#{query}/g;</script></body></html>"
  end

  # Level 6: Reflection in JS multiline comment /* QUERY */
  # Bypass: close comment with */ then close script and inject HTML
  # e.g. */</script><script>alert(1)</script>
  Xssmaze.push("jsctx-level6", "/jsctx/level6/?query=a", "reflection in JS multiline comment (close comment and script)")
  maze_get "/jsctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><script>/* User query: #{query} */ var x = 1;</script></body></html>"
  end
end
