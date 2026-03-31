def load_conditional_reflect_xss
  # Level 1: Reflects only if input length > 5 chars
  # Standard XSS payloads are all > 5 chars, so they pass the check
  Xssmaze.push("condreflect-level1", "/condreflect/level1/?query=a", "reflects only if input length > 5")
  maze_get "/condreflect/level1/" do |env|
    query = env.params.query["query"]

    if query.size > 5
      "<html><body><div>#{query}</div></body></html>"
    else
      "<html><body><div>Input too short</div></body></html>"
    end
  end

  # Level 2: Reflects only if input contains letter 'a'
  # Most payloads contain 'a' (alert, onerror, animate, etc.)
  Xssmaze.push("condreflect-level2", "/condreflect/level2/?query=a", "reflects only if input contains letter a")
  maze_get "/condreflect/level2/" do |env|
    query = env.params.query["query"]

    if query.includes?("a") || query.includes?("A")
      "<html><body><div>#{query}</div></body></html>"
    else
      "<html><body><div>No results</div></body></html>"
    end
  end

  # Level 3: Reflects only if input does NOT start with '<'
  # Payloads prefixed with space like " <img src=x onerror=alert(1)>" bypass this
  Xssmaze.push("condreflect-level3", "/condreflect/level3/?query=a", "reflects only if input does not start with <")
  maze_get "/condreflect/level3/" do |env|
    query = env.params.query["query"]

    if !query.starts_with?("<")
      "<html><body><div>#{query}</div></body></html>"
    else
      "<html><body><div>Blocked</div></body></html>"
    end
  end

  # Level 4: Reflects input twice if it contains '<', once if it doesn't
  # Standard payloads with '<' get double-reflected, both exploitable
  Xssmaze.push("condreflect-level4", "/condreflect/level4/?query=a", "double reflection when input contains <")
  maze_get "/condreflect/level4/" do |env|
    query = env.params.query["query"]

    if query.includes?("<")
      "<html><body><div>#{query}</div><p>Also: #{query}</p></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end

  # Level 5: Always reflects, wraps in <code> if param 'lang' is present, <div> otherwise
  Xssmaze.push("condreflect-level5", "/condreflect/level5/?query=a", "wraps in code tag if lang param present, div otherwise")
  maze_get "/condreflect/level5/" do |env|
    query = env.params.query["query"]
    has_lang = env.params.query.has_key?("lang")

    if has_lang
      "<html><body><code>#{query}</code></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end

  # Level 6: Reflects raw if input < 100 chars, HTML-encodes if >= 100
  # Standard short payloads work fine
  Xssmaze.push("condreflect-level6", "/condreflect/level6/?query=a", "raw reflection if input < 100 chars, encoded otherwise")
  maze_get "/condreflect/level6/" do |env|
    query = env.params.query["query"]

    if query.size < 100
      "<html><body><div>#{query}</div></body></html>"
    else
      encoded = query.gsub("<", "&lt;").gsub(">", "&gt;")
      "<html><body><div>#{encoded}</div></body></html>"
    end
  end
end
