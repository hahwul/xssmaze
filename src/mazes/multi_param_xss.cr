def load_multi_param_xss
  # Level 1: Two params q1 and q2, both reflected raw in body
  # Either param can be exploited independently
  Xssmaze.push("multiparam-level1", "/multiparam/level1/?q1=a&q2=b", "two params both reflected raw (either exploitable)", params: ["q1", "q2"])
  maze_get "/multiparam/level1/" do |env|
    q1 = env.params.query.fetch("q1", "a")
    q2 = env.params.query.fetch("q2", "b")

    "<html><body>
    <h1>Multi-Param Level 1</h1>
    <div>Q1: #{q1}</div>
    <div>Q2: #{q2}</div>
    </body></html>"
  end

  # Level 2: Param "query" reflected raw, but only if param "page" also exists
  # Tests scanner's ability to discover required companion parameters
  Xssmaze.push("multiparam-level2", "/multiparam/level2/?query=a&page=1", "query reflected only when page param exists", params: ["query", "page"])
  maze_get "/multiparam/level2/" do |env|
    query = env.params.query.fetch("query", "a")
    page = env.params.query.fetch("page", "")

    if page.empty?
      "<html><body>
      <h1>Multi-Param Level 2</h1>
      <div>Missing required parameter: page</div>
      </body></html>"
    else
      "<html><body>
      <h1>Multi-Param Level 2</h1>
      <div>Page #{page}: #{query}</div>
      </body></html>"
    end
  end

  # Level 3: Param "search" in input value, param "sort" in input value, both breakable
  # Bypass: break out of attribute with "><img src=x onerror=alert(1)>
  Xssmaze.push("multiparam-level3", "/multiparam/level3/?search=a&sort=b", "two params in input value attributes (both breakable)", params: ["search", "sort"])
  maze_get "/multiparam/level3/" do |env|
    search = env.params.query.fetch("search", "a")
    sort = env.params.query.fetch("sort", "b")

    "<html><body>
    <h1>Multi-Param Level 3</h1>
    <form>
      <input type=\"text\" name=\"search\" value=\"#{search}\">
      <input type=\"text\" name=\"sort\" value=\"#{sort}\">
      <input type=\"submit\" value=\"Go\">
    </form>
    </body></html>"
  end

  # Level 4: Param "query" reflected raw, but only when param "token" equals "valid"
  # Tests scanner's ability to provide a required token value
  Xssmaze.push("multiparam-level4", "/multiparam/level4/?query=a&token=valid", "query reflected only when token=valid", params: ["query", "token"])
  maze_get "/multiparam/level4/" do |env|
    query = env.params.query.fetch("query", "a")
    token = env.params.query.fetch("token", "")

    if token == "valid"
      "<html><body>
      <h1>Multi-Param Level 4</h1>
      <div>Result: #{query}</div>
      </body></html>"
    else
      "<html><body>
      <h1>Multi-Param Level 4</h1>
      <div>Access denied: invalid token</div>
      </body></html>"
    end
  end

  # Level 5: Param "name" reflected raw between "prefix" and "suffix" which are HTML-encoded
  # Only "name" is exploitable; prefix and suffix are safe
  Xssmaze.push("multiparam-level5", "/multiparam/level5/?prefix=a&name=b&suffix=c", "name reflected raw between HTML-encoded prefix and suffix", params: ["prefix", "name", "suffix"])
  maze_get "/multiparam/level5/" do |env|
    prefix = Filters.encode_angles(env.params.query.fetch("prefix", "a"))
    name = env.params.query.fetch("name", "b")
    suffix = Filters.encode_angles(env.params.query.fetch("suffix", "c"))

    "<html><body>
    <h1>Multi-Param Level 5</h1>
    <div>#{prefix}#{name}#{suffix}</div>
    </body></html>"
  end

  # Level 6: Three params a, b, c reflected in different contexts:
  #   a -> HTML body (raw), b -> attribute value, c -> JS string
  # All three are exploitable in their respective contexts
  Xssmaze.push("multiparam-level6", "/multiparam/level6/?a=x&b=y&c=z", "three params in body, attribute, and JS string contexts", params: ["a", "b", "c"])
  maze_get "/multiparam/level6/" do |env|
    a = env.params.query.fetch("a", "x")
    b = env.params.query.fetch("b", "y")
    c = env.params.query.fetch("c", "z")

    "<html><body>
    <h1>Multi-Param Level 6</h1>
    <div>#{a}</div>
    <input type=\"hidden\" name=\"data\" value=\"#{b}\">
    <script>var config = '#{c}';</script>
    </body></html>"
  end
end
