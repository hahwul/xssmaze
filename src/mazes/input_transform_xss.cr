def load_input_transform_xss
  # Level 1: Server prepends "User: " to query and reflects
  # Standard injection — the prefix does not interfere
  Xssmaze.push("inputtransform-level1", "/inputtransform/level1/?query=a", "server prepends prefix before reflection")
  maze_get "/inputtransform/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>User: #{query}</body></html>"
  end

  # Level 2: Server wraps query in <b>QUERY</b>
  # Standard injection — can inject inside or break out of <b>
  Xssmaze.push("inputtransform-level2", "/inputtransform/level2/?query=a", "server wraps query in bold tags")
  maze_get "/inputtransform/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><b>#{query}</b></body></html>"
  end

  # Level 3: Server truncates at first space, then reflects
  # Bypass: use no-space payloads like <svg/onload=alert(1)>
  Xssmaze.push("inputtransform-level3", "/inputtransform/level3/?query=a", "truncate at first space")
  maze_get "/inputtransform/level3/" do |env|
    query = env.params.query["query"]
    query = query.split(" ", 2).first

    "<html><body>#{query}</body></html>"
  end

  # Level 4: Server splits on & and reflects only the first segment
  # Standard injection in the first segment before any &
  Xssmaze.push("inputtransform-level4", "/inputtransform/level4/?query=a", "split on ampersand, reflect first part")
  maze_get "/inputtransform/level4/" do |env|
    query = env.params.query["query"]
    query = query.split("&", 2).first

    "<html><body>#{query}</body></html>"
  end

  # Level 5: Server reverses the string then reflects it (unusable)
  # BUT also reflects the original unreversed query in an HTML comment
  # Bypass: break out of the comment with -->
  Xssmaze.push("inputtransform-level5", "/inputtransform/level5/?query=a", "reversed reflection + original in HTML comment")
  maze_get "/inputtransform/level5/" do |env|
    query = env.params.query["query"]
    reversed = query.reverse

    "<html><body><!-- #{query} --><div>#{reversed}</div></body></html>"
  end

  # Level 6: Server converts query to lowercase then reflects
  # HTML is case-insensitive — lowercase payloads like <script>alert(1)</script> work
  Xssmaze.push("inputtransform-level6", "/inputtransform/level6/?query=a", "lowercase conversion before reflection")
  maze_get "/inputtransform/level6/" do |env|
    query = env.params.query["query"].downcase

    "<html><body>#{query}</body></html>"
  end
end
