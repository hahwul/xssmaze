def load_attribute_event_xss
  # Level 1: Reflection inside onmouseover JS string
  # Query is placed inside a single-quoted JS string in an onmouseover event handler.
  # Bypass: break out with ') then inject new attribute/tag, e.g. ')//
  Xssmaze.push("attr-event-level1", "/attr-event/level1/?query=a", "reflection in onmouseover JS string context")
  maze_get "/attr-event/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div onmouseover=\"show('#{query}')\">hover me</div></body></html>"
  end

  # Level 2: Reflection inside onsubmit JS string
  # Query is placed inside a single-quoted JS string in an onsubmit handler.
  # Bypass: break out with ') then inject handler, e.g. ');alert(1)//
  Xssmaze.push("attr-event-level2", "/attr-event/level2/?query=a", "reflection in onsubmit JS string context")
  maze_get "/attr-event/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><form onsubmit=\"validate('#{query}'); return false\"><input type=\"submit\" value=\"Submit\"></form></body></html>"
  end

  # Level 3: Reflection inside onload JS string
  # Query is placed inside a single-quoted JS string in a body onload handler.
  # Bypass: break out with ') then inject, e.g. ');alert(1)//
  Xssmaze.push("attr-event-level3", "/attr-event/level3/?query=a", "reflection in body onload JS string context")
  maze_get "/attr-event/level3/" do |env|
    query = env.params.query["query"]

    "<html><body onload=\"init('#{query}')\"><p>Page loaded</p></body></html>"
  end

  # Level 4: Reflection inside onerror JS string
  # Query is placed inside a single-quoted JS string in an img onerror handler.
  # The img src is intentionally invalid to trigger onerror.
  # Bypass: break out with ') then inject, e.g. ');alert(1)//
  Xssmaze.push("attr-event-level4", "/attr-event/level4/?query=a", "reflection in img onerror JS string context")
  maze_get "/attr-event/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><img src=\"/nonexistent.jpg\" onerror=\"report('#{query}')\"></body></html>"
  end

  # Level 5: Reflection inside onblur JS string
  # Query is placed inside a single-quoted JS string in an input onblur handler.
  # Bypass: break out with ') then inject, e.g. ');alert(1)//
  Xssmaze.push("attr-event-level5", "/attr-event/level5/?query=a", "reflection in input onblur JS string context")
  maze_get "/attr-event/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><input value=\"test\" onblur=\"save('#{query}')\"></body></html>"
  end

  # Level 6: Reflection inside onclick JS string
  # Query is placed inside a single-quoted JS string in a button onclick handler.
  # Bypass: break out with ') then inject, e.g. ');alert(1)//
  Xssmaze.push("attr-event-level6", "/attr-event/level6/?query=a", "reflection in button onclick JS string context")
  maze_get "/attr-event/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><button onclick=\"action('#{query}')\">Click</button></body></html>"
  end
end
