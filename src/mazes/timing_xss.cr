def load_timing_xss
  # Level 1: Reflection in <script> variable assignment with double quotes
  # Exploit: query=";alert(1)// or query=";</script><script>alert(1)</script>
  Xssmaze.push("timing-level1", "/timing/level1/?query=a", "reflection in JS double-quoted string assignment")
  maze_get "/timing/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 1</h1>
    <script>var x = \"#{query}\";</script>
    </body></html>"
  end

  # Level 2: Reflection in JS object key
  # Exploit: query=x}; alert(1);// or query=x: "value"}; alert(1); var y = {z
  Xssmaze.push("timing-level2", "/timing/level2/?query=a", "reflection in JS object key")
  maze_get "/timing/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 2</h1>
    <script>var obj = {#{query}: \"value\"};</script>
    </body></html>"
  end

  # Level 3: Reflection after // JS single-line comment (newline breaks out)
  # Exploit: query=%0aalert(1)// (newline escapes the comment)
  Xssmaze.push("timing-level3", "/timing/level3/?query=a", "reflection after JS line comment (newline breakout)")
  maze_get "/timing/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 3</h1>
    <script>// #{query}\nvar a = 1;</script>
    </body></html>"
  end

  # Level 4: Reflection inside JS regex literal
  # Exploit: query=/;alert(1)// (close regex then inject)
  Xssmaze.push("timing-level4", "/timing/level4/?query=a", "reflection inside JS regex literal")
  maze_get "/timing/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 4</h1>
    <script>var re = /#{query}/;</script>
    </body></html>"
  end

  # Level 5: Reflection in <script> with single-quote string
  # Exploit: query=';alert(1)// or query=';</script><script>alert(1)</script>
  Xssmaze.push("timing-level5", "/timing/level5/?query=a", "reflection in JS single-quoted string")
  maze_get "/timing/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 5</h1>
    <script>var msg = '#{query}';</script>
    </body></html>"
  end

  # Level 6: Reflection in JS template literal (backtick string)
  # Exploit: query=${alert(1)} or query=`;</script><script>alert(1)</script>
  Xssmaze.push("timing-level6", "/timing/level6/?query=a", "reflection in JS template literal (backtick)")
  maze_get "/timing/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Timing XSS Level 6</h1>
    <script>var t = `Hello #{query}`;</script>
    </body></html>"
  end
end
