def load_payload_filter_xss
  # Level 1: Blocks input containing both < AND > together - reflected in input value (attr breakout, no angle brackets needed)
  Xssmaze.push("payloadfilt-level1", "/payloadfilt/level1/?query=a", "blocks < and > together, reflected in input value (attr breakout)")
  maze_get "/payloadfilt/level1/" do |env|
    query = env.params.query["query"]

    if query.includes?("<") && query.includes?(">")
      "<html><body><p>Blocked: angle brackets not allowed</p></body></html>"
    else
      "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
    end
  end

  # Level 2: Blocks input containing "script" (case insensitive) - use img/svg tags instead
  Xssmaze.push("payloadfilt-level2", "/payloadfilt/level2/?query=a", "blocks 'script' keyword (case insensitive), use img/svg tags")
  maze_get "/payloadfilt/level2/" do |env|
    query = env.params.query["query"]

    if query.downcase.includes?("script")
      "<html><body><p>Blocked: script keyword detected</p></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end

  # Level 3: Blocks input > 80 chars AND containing < - use short payload under 80 chars
  Xssmaze.push("payloadfilt-level3", "/payloadfilt/level3/?query=a", "blocks input >80 chars with <, use short payload")
  maze_get "/payloadfilt/level3/" do |env|
    query = env.params.query["query"]

    if query.size > 80 && query.includes?("<")
      "<html><body><p>Blocked: payload too long with HTML</p></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end

  # Level 4: Blocks alert(, confirm(, prompt( - use other JS functions like print() or top-level throw
  Xssmaze.push("payloadfilt-level4", "/payloadfilt/level4/?query=a", "blocks alert(/confirm(/prompt(, use alternative JS functions")
  maze_get "/payloadfilt/level4/" do |env|
    query = env.params.query["query"]

    if query.downcase.includes?("alert(") || query.downcase.includes?("confirm(") || query.downcase.includes?("prompt(")
      "<html><body><p>Blocked: dangerous function call detected</p></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end

  # Level 5: Blocks input matching <\w+[\s/] (opening HTML tag pattern) - reflected in attr value, breakout needs no tag
  Xssmaze.push("payloadfilt-level5", "/payloadfilt/level5/?query=a", "blocks opening HTML tag pattern, reflected in attr (attr breakout)")
  maze_get "/payloadfilt/level5/" do |env|
    query = env.params.query["query"]

    if query.matches?(/<\w+[\s\/]/)
      "<html><body><p>Blocked: HTML tag pattern detected</p></body></html>"
    else
      "<html><body><input type=\"text\" value=\"#{query}\"></body></html>"
    end
  end

  # Level 6: Blocks input containing "on" followed by "=" (with any chars between) - use <script> tags (no event handlers)
  Xssmaze.push("payloadfilt-level6", "/payloadfilt/level6/?query=a", "blocks on...= pattern (event handlers), use script tags instead")
  maze_get "/payloadfilt/level6/" do |env|
    query = env.params.query["query"]

    if query.matches?(/on.+=/i)
      "<html><body><p>Blocked: event handler pattern detected</p></body></html>"
    else
      "<html><body><div>#{query}</div></body></html>"
    end
  end
end
