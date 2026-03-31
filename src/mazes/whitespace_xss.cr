def load_whitespace_xss
  # Level 1: All spaces replaced by &nbsp; but in HTML body — tags still work
  # Use / as attribute delimiter instead of space: <img/src=x/onerror=alert(1)>
  Xssmaze.push("whitespace-level1", "/whitespace/level1/?query=a", "spaces replaced with &amp;nbsp; in body")
  maze_get "/whitespace/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(" ", "&nbsp;")

    "<html><body>
    <h1>Whitespace XSS Level 1</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 2: Tabs stripped, reflected in HTML body — spaces still work for tags
  Xssmaze.push("whitespace-level2", "/whitespace/level2/?query=a", "tabs stripped, body reflection")
  maze_get "/whitespace/level2/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("\t", "")

    "<html><body>
    <h1>Whitespace XSS Level 2</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 3: Newlines stripped, reflected in HTML body — single-line payloads work normally
  Xssmaze.push("whitespace-level3", "/whitespace/level3/?query=a", "newlines stripped, body reflection")
  maze_get "/whitespace/level3/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("\n", "").gsub("\r", "")

    "<html><body>
    <h1>Whitespace XSS Level 3</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 4: Multiple spaces collapsed to one, reflected in <div> — standard injection works
  Xssmaze.push("whitespace-level4", "/whitespace/level4/?query=a", "multiple spaces collapsed to one in div")
  maze_get "/whitespace/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/  +/, " ")

    "<html><body>
    <h1>Whitespace XSS Level 4</h1>
    <div>#{filtered}</div>
    </body></html>"
  end

  # Level 5: Reflected inside <pre> tag raw (preserves whitespace) — break out with </pre>
  Xssmaze.push("whitespace-level5", "/whitespace/level5/?query=a", "raw reflection inside pre tag")
  maze_get "/whitespace/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Whitespace XSS Level 5</h1>
    <pre>#{query}</pre>
    </body></html>"
  end

  # Level 6: All whitespace (space, tab, newline) stripped, reflected in HTML body
  # Use / as delimiter: <svg/onload=alert(1)>
  Xssmaze.push("whitespace-level6", "/whitespace/level6/?query=a", "all whitespace stripped, body reflection")
  maze_get "/whitespace/level6/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/[\s]/, "")

    "<html><body>
    <h1>Whitespace XSS Level 6</h1>
    <div>#{filtered}</div>
    </body></html>"
  end
end
