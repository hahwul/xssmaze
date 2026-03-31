def load_inline_style_xss
  # Level 1: Reflected in <div style="color: QUERY">
  # Bypass: break out of style attribute with " then inject event handler
  # e.g. red" onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level1", "/inlinestyle/level1/?query=a", "reflection in inline style color value (double-quoted)")
  maze_get "/inlinestyle/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div style=\"color: #{query}\">text</div>
    </body></html>"
  end

  # Level 2: Reflected in <p style="background-image: url('QUERY')">
  # Bypass: break out of url() with ' then out of style with "
  # e.g. x') " onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level2", "/inlinestyle/level2/?query=a", "reflection inside url() in inline style (single-quoted url, double-quoted attr)")
  maze_get "/inlinestyle/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <p style=\"background-image: url('#{query}')\">text</p>
    </body></html>"
  end

  # Level 3: Reflected in <span style="font-family: 'QUERY'">
  # Bypass: break out of font-family with ' then out of style attribute with "
  # e.g. x'" onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level3", "/inlinestyle/level3/?query=a", "reflection inside font-family in inline style (single-quoted value, double-quoted attr)")
  maze_get "/inlinestyle/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <span style=\"font-family: '#{query}'\">text</span>
    </body></html>"
  end

  # Level 4: Reflected in <div style="content: 'QUERY'">
  # Bypass: break out of content with ' then out of style attribute with "
  # e.g. x'" onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level4", "/inlinestyle/level4/?query=a", "reflection inside content in inline style (single-quoted value, double-quoted attr)")
  maze_get "/inlinestyle/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div style=\"content: '#{query}'\">text</div>
    </body></html>"
  end

  # Level 5: Reflected in <td style="width: QUERY">
  # Bypass: close attribute with " then inject event handler
  # e.g. 100px" onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level5", "/inlinestyle/level5/?query=a", "reflection in inline style width value (no inner quotes, double-quoted attr)")
  maze_get "/inlinestyle/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <table><tr><td style=\"width: #{query}\">data</td></tr></table>
    </body></html>"
  end

  # Level 6: Reflected in <div style="QUERY">
  # Bypass: full control of style value, break out with " then inject event handler
  # e.g. color:red" onmouseover="alert(1)
  Xssmaze.push("inlinestyle-level6", "/inlinestyle/level6/?query=a", "reflection as entire inline style value (double-quoted attr)")
  maze_get "/inlinestyle/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <div style=\"#{query}\">text</div>
    </body></html>"
  end
end
