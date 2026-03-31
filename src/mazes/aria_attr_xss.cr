def load_aria_attr_xss
  # Level 1: Reflected in <div role="alert" aria-label="QUERY">
  # Bypass: break out of aria-label with " then inject event handler
  Xssmaze.push("ariaattr-level1", "/ariaattr/level1/?query=a", "reflection in aria-label attribute (double-quoted)")
  maze_get "/ariaattr/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div role=\"alert\" aria-label=\"#{query}\">notification</div>
    </body></html>"
  end

  # Level 2: Reflected in <input aria-describedby="QUERY" type="text">
  # Bypass: break out of aria-describedby with " then inject event handler
  Xssmaze.push("ariaattr-level2", "/ariaattr/level2/?query=a", "reflection in aria-describedby attribute (double-quoted)")
  maze_get "/ariaattr/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <input aria-describedby=\"#{query}\" type=\"text\">
    </body></html>"
  end

  # Level 3: Reflected in <span aria-live="polite" aria-atomic="QUERY">
  # Bypass: break out of aria-atomic with " then inject event handler
  Xssmaze.push("ariaattr-level3", "/ariaattr/level3/?query=a", "reflection in aria-atomic attribute (double-quoted)")
  maze_get "/ariaattr/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <span aria-live=\"polite\" aria-atomic=\"#{query}\">updates</span>
    </body></html>"
  end

  # Level 4: Reflected in <div role="tooltip" aria-hidden="QUERY">
  # Bypass: break out of aria-hidden with " then inject event handler
  Xssmaze.push("ariaattr-level4", "/ariaattr/level4/?query=a", "reflection in aria-hidden attribute (double-quoted)")
  maze_get "/ariaattr/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div role=\"tooltip\" aria-hidden=\"#{query}\">tooltip text</div>
    </body></html>"
  end

  # Level 5: Reflected in <nav aria-label="QUERY">
  # Bypass: break out of aria-label with " then inject event handler
  Xssmaze.push("ariaattr-level5", "/ariaattr/level5/?query=a", "reflection in nav aria-label attribute (double-quoted)")
  maze_get "/ariaattr/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <nav aria-label=\"#{query}\">
      <ul><li><a href=\"#\">Home</a></li></ul>
    </nav>
    </body></html>"
  end

  # Level 6: Reflected in <div role="QUERY" aria-relevant="additions">
  # Bypass: break out of role with " then inject event handler
  Xssmaze.push("ariaattr-level6", "/ariaattr/level6/?query=a", "reflection in role attribute (double-quoted)")
  maze_get "/ariaattr/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div role=\"#{query}\" aria-relevant=\"additions\">content</div>
    </body></html>"
  end
end
