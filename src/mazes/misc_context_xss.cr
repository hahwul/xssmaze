def load_misc_context_xss
  # Level 1: progress element - reflection inside title attribute
  # Bypass: break out of title with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level1", "/misc-context/level1/?query=a", "progress element title attribute reflection")
  maze_get "/misc-context/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><label>Upload Progress:</label><br><progress value=\"50\" max=\"100\" title=\"#{query}\">50%</progress></div></body></html>"
  end

  # Level 2: meter element - reflection inside title attribute
  # Bypass: break out of title with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level2", "/misc-context/level2/?query=a", "meter element title attribute reflection")
  maze_get "/misc-context/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><label>Disk Usage:</label><br><meter min=\"0\" max=\"100\" value=\"75\" title=\"#{query}\">75%</meter></div></body></html>"
  end

  # Level 3: time element - reflection inside datetime attribute
  # Bypass: break out of datetime with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level3", "/misc-context/level3/?query=a", "time element datetime attribute reflection")
  maze_get "/misc-context/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><p>Published on <time datetime=\"#{query}\">March 2024</time></p></div></body></html>"
  end

  # Level 4: data element - reflection inside value attribute
  # Bypass: break out of value with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level4", "/misc-context/level4/?query=a", "data element value attribute reflection")
  maze_get "/misc-context/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><p>Product ID: <data value=\"#{query}\">Product 123</data></p></div></body></html>"
  end

  # Level 5: cite element - reflection inside title attribute
  # Bypass: break out of title with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level5", "/misc-context/level5/?query=a", "cite element title attribute reflection")
  maze_get "/misc-context/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><blockquote><p>The only way to do great work is to love what you do.</p><footer>-- <cite title=\"#{query}\">Source Name</cite></footer></blockquote></div></body></html>"
  end

  # Level 6: q element - reflection inside cite attribute
  # Bypass: break out of cite with ", e.g. " onmouseover="alert(1)"
  Xssmaze.push("misc-context-level6", "/misc-context/level6/?query=a", "q element cite attribute reflection")
  maze_get "/misc-context/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><div style=\"padding:20px\"><p>As they say: <q cite=\"#{query}\">quoted text</q></p></div></body></html>"
  end
end
