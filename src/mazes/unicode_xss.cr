def load_unicode_xss
  # Level 1: Fullwidth character normalization - converts fullwidth < > to ASCII before reflection
  # The filter converts fullwidth chars to ASCII first, then reflects. Regular < > still work.
  # Exploit: query=<script>alert(1)</script> (regular ASCII chars pass through)
  Xssmaze.push("unicode-level1", "/unicode/level1/?query=a", "fullwidth normalization (regular ASCII angles still work)")
  maze_get "/unicode/level1/" do |env|
    query = env.params.query["query"]
    # Normalize fullwidth to ASCII
    query = query.gsub("\uFF1C", "<").gsub("\uFF1E", ">")

    "<html><body>
    <h1>Unicode XSS Level 1</h1>
    #{query}
    </body></html>"
  end

  # Level 2: Strip ASCII < > but allow unicode fullwidth, then normalize to ASCII before output
  # Exploit: query=%EF%BC%9Cscript%EF%BC%9Ealert(1)%EF%BC%9C/script%EF%BC%9E (fullwidth angles bypass strip, then become real)
  Xssmaze.push("unicode-level2", "/unicode/level2/?query=a", "strip ASCII angles then normalize fullwidth (order-of-ops bypass)")
  maze_get "/unicode/level2/" do |env|
    query = env.params.query["query"]
    # Step 1: Strip ASCII angle brackets
    query = query.gsub("<", "").gsub(">", "")
    # Step 2: Normalize fullwidth to ASCII (vulnerable: fullwidth survives step 1)
    query = query.gsub("\uFF1C", "<").gsub("\uFF1E", ">")

    "<html><body>
    <h1>Unicode XSS Level 2</h1>
    #{query}
    </body></html>"
  end

  # Level 3: Reflection with null bytes stripped
  # Exploit: query=<script>alert(1)</script> (null bytes are stripped but all other chars pass through)
  Xssmaze.push("unicode-level3", "/unicode/level3/?query=a", "null byte stripping only (all other chars reflected)")
  maze_get "/unicode/level3/" do |env|
    query = env.params.query["query"]
    query = query.gsub("\0", "")

    "<html><body>
    <h1>Unicode XSS Level 3</h1>
    #{query}
    </body></html>"
  end

  # Level 4: UTF-7 encoding hint via Content-Type charset
  # Exploit: query=+ADw-script+AD4-alert(1)+ADw-/script+AD4- (UTF-7 encoded XSS)
  Xssmaze.push("unicode-level4", "/unicode/level4/?query=a", "UTF-7 charset with raw reflection")
  maze_get "/unicode/level4/" do |env|
    query = env.params.query["query"]
    env.response.content_type = "text/html; charset=utf-7"

    "<html><body>
    <h1>Unicode XSS Level 4</h1>
    #{query}
    </body></html>"
  end

  # Level 5: Right-to-left override character injection in attribute
  # Exploit: query=" onfocus=alert(1) autofocus=" (standard attribute breakout)
  Xssmaze.push("unicode-level5", "/unicode/level5/?query=a", "reflection in attribute (RLO/bidi chars allowed)")
  maze_get "/unicode/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Unicode XSS Level 5</h1>
    <div title=\"#{query}\">Hover over this text</div>
    </body></html>"
  end

  # Level 6: Reflection with backslash stripping only - strips \ but allows < > " '
  # Exploit: query=<img src=x onerror=alert(1)> (angle brackets and quotes are not filtered)
  Xssmaze.push("unicode-level6", "/unicode/level6/?query=a", "backslash stripping only (angles and quotes allowed)")
  maze_get "/unicode/level6/" do |env|
    query = env.params.query["query"]
    query = query.gsub("\\", "")

    "<html><body>
    <h1>Unicode XSS Level 6</h1>
    #{query}
    </body></html>"
  end
end
