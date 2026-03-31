def load_data_attribute_xss
  # Level 1: Reflected in <div data-value="QUERY">
  # Bypass: " onfocus=alert(1) autofocus x="
  Xssmaze.push("dataattr-level1", "/data-attribute/level1/?query=a", "reflected in data-value double-quoted attribute")
  maze_get "/data-attribute/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div data-value=\"#{query}\">content</div></body></html>"
  end

  # Level 2: Reflected in single-quoted attribute with JSON content
  # Bypass: ' onfocus=alert(1) autofocus x='
  Xssmaze.push("dataattr-level2", "/data-attribute/level2/?query=a", "reflected in single-quoted data-config JSON attribute")
  maze_get "/data-attribute/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div data-config='{\"name\":\"" + query + "\"}'>config</div></body></html>"
  end

  # Level 3: Reflected in <span data-tooltip="QUERY" class="tip">
  # Bypass: " onfocus=alert(1) autofocus x="
  Xssmaze.push("dataattr-level3", "/data-attribute/level3/?query=a", "reflected in data-tooltip double-quoted attribute")
  maze_get "/data-attribute/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><span data-tooltip=\"#{query}\" class=\"tip\">hover me</span></body></html>"
  end

  # Level 4: Reflected in <button data-action="click->controller#QUERY">
  # Bypass: " onfocus=alert(1) autofocus x="
  Xssmaze.push("dataattr-level4", "/data-attribute/level4/?query=a", "reflected in data-action Stimulus-style attribute")
  maze_get "/data-attribute/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><button data-action=\"click->controller##{query}\">Click</button></body></html>"
  end

  # Level 5: Reflected in single-quoted <div data-src='QUERY'> where ' is NOT encoded
  # Bypass: ' onfocus=alert(1) autofocus x='
  Xssmaze.push("dataattr-level5", "/data-attribute/level5/?query=a", "reflected in single-quoted data-src (double-quote encoded only)")
  maze_get "/data-attribute/level5/" do |env|
    query = env.params.query["query"]
    encoded = query.gsub("\"", "&quot;")

    "<html><body><div data-src='#{encoded}'>image</div></body></html>"
  end

  # Level 6: Reflected in <tr data-url="QUERY"> inside a table
  # Bypass: " onfocus=alert(1) autofocus x="
  Xssmaze.push("dataattr-level6", "/data-attribute/level6/?query=a", "reflected in data-url attribute inside table row")
  maze_get "/data-attribute/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><table><tr data-url=\"#{query}\"><td>Row 1</td></tr></table></body></html>"
  end
end
