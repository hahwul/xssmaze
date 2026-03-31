def load_script_gadget_xss
  # Level 1: Query in JS object property value — close the string, close the script, inject HTML
  Xssmaze.push("scriptgadget-level1", "/scriptgadget/level1/?query=a", "query in JS object property value (close script to inject)")
  maze_get "/scriptgadget/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
<script>var config = {name: \"#{query}\", id: 1};</script>
<p>Config loaded.</p>
</body></html>"
  end

  # Level 2: Query in JS ternary expression — close the string, close the script, inject HTML
  Xssmaze.push("scriptgadget-level2", "/scriptgadget/level2/?query=a", "query in JS ternary expression (close script to inject)")
  maze_get "/scriptgadget/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
<script>var x = true ? \"#{query}\" : \"default\";</script>
<p>Ternary evaluated.</p>
</body></html>"
  end

  # Level 3: Query in JS string concatenation — close the string, close the script, inject HTML
  Xssmaze.push("scriptgadget-level3", "/scriptgadget/level3/?query=a", "query in JS string concatenation (close script to inject)")
  maze_get "/scriptgadget/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
<script>var msg = \"Hello \" + \"#{query}\" + \"!\";</script>
<p>Message ready.</p>
</body></html>"
  end

  # Level 4: Query in JS function call argument — close the string, close the script, inject HTML
  Xssmaze.push("scriptgadget-level4", "/scriptgadget/level4/?query=a", "query in JS function call arg (close script to inject)")
  maze_get "/scriptgadget/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
<script>function init(a, b) { return a; } init(\"#{query}\", {debug: false});</script>
<p>Initialized.</p>
</body></html>"
  end

  # Level 5: Query in inline event handler — break out of the event attribute with ') then inject new attribute
  # Angle brackets are stripped so you cannot close the tag and inject new tags
  # Must use event attribute injection: ') followed by onmouseover=alert(1) or similar
  Xssmaze.push("scriptgadget-level5", "/scriptgadget/level5/?query=a", "query in onclick handler attr (break out, add event attr)")
  maze_get "/scriptgadget/level5/" do |env|
    query = Filters.strip_angles(env.params.query["query"])

    "<html><body>
<div onclick=\"handle('#{query}')\" style=\"padding:20px;background:#eee;cursor:pointer;\">Click here</div>
</body></html>"
  end

  # Level 6: Query in script with JS template literal — close the script, inject HTML
  Xssmaze.push("scriptgadget-level6", "/scriptgadget/level6/?query=a", "query in JS template literal inside script (close script to inject)")
  maze_get "/scriptgadget/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
<script>var name = \"World\"; var t = `Hello ${name}, #{query}`;</script>
<p>Template rendered.</p>
</body></html>"
  end
end
