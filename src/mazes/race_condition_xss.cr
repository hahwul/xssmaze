def load_race_condition_xss
  # Level 1: Reflection inside <style> tag (CSS context injection)
  # Exploit: query="></style><script>alert(1)</script>
  Xssmaze.push("racecon-level1", "/racecon/level1/?query=a", "reflection inside style tag (CSS context)")
  maze_get "/racecon/level1/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <style>body { font-family: \"#{query}\"; }</style>
    </head><body>
    <h1>Race Condition XSS Level 1</h1>
    <p>Styled page</p>
    </body></html>"
  end

  # Level 2: Reflection in <textarea> without encoding (must close textarea first)
  # Exploit: query=</textarea><script>alert(1)</script>
  Xssmaze.push("racecon-level2", "/racecon/level2/?query=a", "reflection inside textarea (raw, no encoding)")
  maze_get "/racecon/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Race Condition XSS Level 2</h1>
    <form>
    <textarea name=\"content\">#{query}</textarea>
    <button type=\"submit\">Submit</button>
    </form>
    </body></html>"
  end

  # Level 3: Reflection in SVG <text> element (SVG context)
  # Exploit: query=</text><svg onload=alert(1)> or query=</text><script>alert(1)</script>
  Xssmaze.push("racecon-level3", "/racecon/level3/?query=a", "reflection inside SVG text element")
  maze_get "/racecon/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Race Condition XSS Level 3</h1>
    <svg width=\"400\" height=\"100\">
      <text x=\"10\" y=\"50\" font-size=\"20\">#{query}</text>
    </svg>
    </body></html>"
  end

  # Level 4: Reflection inside <title> tag (must close title to inject)
  # Exploit: query=</title><script>alert(1)</script>
  Xssmaze.push("racecon-level4", "/racecon/level4/?query=a", "reflection inside title tag")
  maze_get "/racecon/level4/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <title>#{query}</title>
    </head><body>
    <h1>Race Condition XSS Level 4</h1>
    <p>safe content</p>
    </body></html>"
  end
end
