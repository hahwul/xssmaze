def load_nested_context_xss
  # Level 1: Reflected in div title attribute with a script tag sibling - break out of title attribute
  Xssmaze.push("nestedctx-level1", "/nestedctx/level1/?query=a", "reflected in div title attribute next to script tag")
  maze_get "/nestedctx/level1/" do |env|
    query = env.params.query["query"]
    "<html><body><div title=\"#{query}\"><script>var a=\"safe\";</script></div></body></html>"
  end

  # Level 2: Reflected inside a div inside textarea - must break out of textarea first
  Xssmaze.push("nestedctx-level2", "/nestedctx/level2/?query=a", "reflected inside div inside textarea (must escape textarea)")
  maze_get "/nestedctx/level2/" do |env|
    query = env.params.query["query"]
    "<html><body><textarea><div title=\"#{query}\"></div></textarea></body></html>"
  end

  # Level 3: Reflected inside a JS string that contains HTML markup - close the script tag
  Xssmaze.push("nestedctx-level3", "/nestedctx/level3/?query=a", "reflected in JS string containing HTML (close script tag)")
  maze_get "/nestedctx/level3/" do |env|
    query = env.params.query["query"]
    "<html><body><script>var a=\"<div>#{query}</div>\";</script></body></html>"
  end

  # Level 4: Reflected inside title element within SVG - break out of SVG title
  Xssmaze.push("nestedctx-level4", "/nestedctx/level4/?query=a", "reflected inside title element within SVG context")
  maze_get "/nestedctx/level4/" do |env|
    query = env.params.query["query"]
    "<html><body><svg><rect><title>#{query}</title></rect></svg></body></html>"
  end

  # Level 5: Reflected inside CSS comment within style tag - close style tag to inject
  Xssmaze.push("nestedctx-level5", "/nestedctx/level5/?query=a", "reflected inside CSS comment within style tag")
  maze_get "/nestedctx/level5/" do |env|
    query = env.params.query["query"]
    "<html><head><style>/* #{query} */body{color:red}</style></head><body><p>Content</p></body></html>"
  end

  # Level 6: Reflected in data-x attribute of div containing an img - break out of attribute
  Xssmaze.push("nestedctx-level6", "/nestedctx/level6/?query=a", "reflected in data attribute of div with child img element")
  maze_get "/nestedctx/level6/" do |env|
    query = env.params.query["query"]
    "<html><body><div data-x=\"#{query}\"><img src=\"safe.jpg\"></div></body></html>"
  end
end
