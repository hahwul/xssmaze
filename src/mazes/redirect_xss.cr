def load_redirect_xss
  # Level 1: Reflection in <a href="QUERY"> with no filtering
  # Bypass: javascript:alert(1)
  Xssmaze.push("redirectxss-level1", "/redirectxss/level1/?query=a", "reflection in href attribute unfiltered (javascript: protocol)")
  maze_get "/redirectxss/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"#{query}\">Click here</a></body></html>"
  end

  # Level 2: Reflection in meta refresh <meta http-equiv="refresh" content="0;url=QUERY">
  # Bypass: javascript:alert(1) or data: URI
  Xssmaze.push("redirectxss-level2", "/redirectxss/level2/?query=a", "reflection in meta refresh URL")
  maze_get "/redirectxss/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><meta http-equiv=\"refresh\" content=\"0;url=#{query}\"></head><body>Redirecting...</body></html>"
  end

  # Level 3: Reflection in <form action="QUERY">
  # Bypass: javascript:alert(1)
  Xssmaze.push("redirectxss-level3", "/redirectxss/level3/?query=a", "reflection in form action attribute (javascript: protocol)")
  maze_get "/redirectxss/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><form action=\"#{query}\"><input type='submit' value='Submit'></form></body></html>"
  end

  # Level 4: Reflection in window.location assignment inside script
  # Bypass: close script tag </script><script>alert(1)</script>
  Xssmaze.push("redirectxss-level4", "/redirectxss/level4/?query=a", "reflection in window.location assignment inside script")
  maze_get "/redirectxss/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><script>window.location=\"#{query}\";</script></body></html>"
  end

  # Level 5: Query param reflected in <a href="/redirect?url=QUERY">
  # Bypass: break out of attribute with "> and inject HTML
  Xssmaze.push("redirectxss-level5", "/redirectxss/level5/?query=a", "reflection in href URL param (attribute breakout)")
  maze_get "/redirectxss/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><a href=\"/redirect?url=#{query}\">Click to redirect</a></body></html>"
  end

  # Level 6: Reflection in <object data="QUERY">
  # Bypass: javascript:alert(1) or data: URI
  Xssmaze.push("redirectxss-level6", "/redirectxss/level6/?query=a", "reflection in object data attribute (javascript: or data: URI)")
  maze_get "/redirectxss/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><object data=\"#{query}\"></object></body></html>"
  end
end
