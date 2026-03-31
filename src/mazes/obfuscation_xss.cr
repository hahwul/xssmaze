def load_obfuscation_xss
  # Level 1: Server lowercases the entire input then reflects in body
  # Bypass: lowercase payloads work fine, e.g. <img src=x onerror=alert(1)>
  Xssmaze.push("obfuscation-level1", "/obfuscation/level1/?query=a", "server lowercases input then reflects (lowercase payloads work)")
  maze_get "/obfuscation/level1/" do |env|
    query = env.params.query["query"].downcase

    "<html><body>
    <h1>Obfuscation Level 1</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 2: Server uppercases the entire input then reflects in body
  # Bypass: HTML tags are case-insensitive, <IMG SRC=X ONERROR=ALERT(1)> works
  Xssmaze.push("obfuscation-level2", "/obfuscation/level2/?query=a", "server uppercases input then reflects (HTML is case-insensitive)")
  maze_get "/obfuscation/level2/" do |env|
    query = env.params.query["query"].upcase

    "<html><body>
    <h1>Obfuscation Level 2</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 3: Server reflects both reversed and original copy of input
  # The original (non-reversed) copy is exploitable by standard payloads
  Xssmaze.push("obfuscation-level3", "/obfuscation/level3/?query=a", "reflects reversed + original (original is exploitable)")
  maze_get "/obfuscation/level3/" do |env|
    query = env.params.query["query"]
    reversed = query.reverse

    "<html><body>
    <h1>Obfuscation Level 3</h1>
    <div class=\"reversed\">#{reversed}</div>
    <div class=\"original\">#{query}</div>
    </body></html>"
  end

  # Level 4: Server removes all spaces then reflects in body
  # Bypass: use / as attribute separator, e.g. <img/src=x/onerror=alert(1)>
  Xssmaze.push("obfuscation-level4", "/obfuscation/level4/?query=a", "server strips all spaces then reflects (use / separator)")
  maze_get "/obfuscation/level4/" do |env|
    query = env.params.query["query"].gsub(" ", "")

    "<html><body>
    <h1>Obfuscation Level 4</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 5: Server removes all = characters then reflects inside <div>
  # Bypass: use tags that don't need =, e.g. <script>alert(1)</script>
  Xssmaze.push("obfuscation-level5", "/obfuscation/level5/?query=a", "server strips = chars then reflects (use script tag)")
  maze_get "/obfuscation/level5/" do |env|
    query = env.params.query["query"].gsub("=", "")

    "<html><body>
    <h1>Obfuscation Level 5</h1>
    <div>#{query}</div>
    </body></html>"
  end

  # Level 6: Server removes ( and ) parentheses then reflects inside <div>
  # Bypass: use backticks for function calls, e.g. <img src=x onerror=alert`1`>
  # Or use tags that don't need parens at all
  Xssmaze.push("obfuscation-level6", "/obfuscation/level6/?query=a", "server strips parentheses then reflects (use backticks)")
  maze_get "/obfuscation/level6/" do |env|
    query = env.params.query["query"].gsub("(", "").gsub(")", "")

    "<html><body>
    <h1>Obfuscation Level 6</h1>
    <div>#{query}</div>
    </body></html>"
  end
end
