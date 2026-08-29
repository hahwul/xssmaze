# Level 1: Strips "script" keyword (case-insensitive, single pass)
# Bypass: <scr<script>ipt>alert(1)</scr</script>ipt> — after single-pass removal of "script",
# the outer fragments rejoin into <script>alert(1)</script>
Xssmaze.push("wafv2-level1", "/wafv2/level1/?query=a", "single-pass case-insensitive 'script' strip (rejoin bypass)",
  vuln: "reflected-html", delivery: ["query"], note: "\"script\" is removed case-insensitively in a single pass, so <scr<script>ipt> rejoins")
maze_get "/wafv2/level1/" do |env|
  query = Filters.strip_keyword_ci(env.params.query.fetch("query", ""), "script")

  "<html><body>#{query}</body></html>"
end

# Level 2: Strips event handlers matching on\w+= pattern
# Bypass: use <script>alert(1)</script> which has no event handler,
# or <svg><set attributeName=onmouseover to=alert(1)> (no = after onmouseover in source)
Xssmaze.push("wafv2-level2", "/wafv2/level2/?query=a", "event handler on\\w+= pattern strip (script tag bypass)",
  vuln: "reflected-html", delivery: ["query"], note: "on...= handlers are stripped, and a plain <script> tag has none")
maze_get "/wafv2/level2/" do |env|
  query = Filters.strip_event_handlers(env.params.query.fetch("query", ""))

  "<html><body>#{query}</body></html>"
end

# Level 3: Replaces alert, confirm, prompt with empty string (case-insensitive, single pass)
# Bypass: use other JS functions like eval('ale'+'rt(1)'), top['al'+'ert'](1),
# or use String.fromCharCode, or just use <script>throw onerror=eval,'=alert\x281\x29'</script>
# Simplest for scanner: <img src=x onerror=eval(atob('YWxlcnQoMSk='))>
# Or: <img src=x onerror=window['ale'+'rt'](1)>
# Or: <script>eval('al'+'ert(1)')</script>
Xssmaze.push("wafv2-level3", "/wafv2/level3/?query=a", "alert/confirm/prompt function name strip",
  vuln: "reflected-html", delivery: ["query"], note: "alert/confirm/prompt are stripped by name, so build the call another way")
maze_get "/wafv2/level3/" do |env|
  query = Filters.strip_keyword_ci(env.params.query.fetch("query", ""), "alert")
  query = Filters.strip_keyword_ci(query, "confirm")
  query = Filters.strip_keyword_ci(query, "prompt")

  "<html><body>#{query}</body></html>"
end

# Level 4: Blocks if input length > 50 chars, reflects raw otherwise
# Bypass: use short payloads like <svg/onload=alert(1)> (27 chars)
# or <img src=x onerror=alert(1)> (30 chars)
Xssmaze.push("wafv2-level4", "/wafv2/level4/?query=a", "length limit: blocked if > 50 chars",
  vuln: "reflected-html", delivery: ["query"], note: "values over 50 characters are blocked outright")
maze_get "/wafv2/level4/" do |env|
  query = env.params.query.fetch("query", "")

  if query.size > 50
    "<html><body><p>Input too long — blocked by WAF.</p></body></html>"
  else
    "<html><body>#{query}</body></html>"
  end
end

# Level 5: Strips < followed by any alpha char (blocks <script, <img, <svg, etc.)
# Reflection is inside a value="" attribute, so no < needed — break out of attribute
# Bypass: " onmouseover=alert(1) x=" or " autofocus onfocus=alert(1) x="
Xssmaze.push("wafv2-level5", "/wafv2/level5/?query=a", "strip <[a-zA-Z] pattern, reflected in value attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "< followed by a letter is stripped, so no tag can be opened; the reflection is in an input value, so break out of the attribute")
maze_get "/wafv2/level5/" do |env|
  query = env.params.query.fetch("query", "").gsub(/<[a-zA-Z]/, "")

  "<html><body><input type=\"text\" value=\"#{query}\" class=\"search\"></body></html>"
end

# Level 6: Multiple filters combined — strips <script> and </script> tags,
# encodes " to &quot;, but allows ' (single quotes) and does NOT encode < > for non-script tags
# Bypass: <img src=x onerror='alert(1)'> works because img tags pass through and ' is unescaped
Xssmaze.push("wafv2-level6", "/wafv2/level6/?query=a", "multi-filter: script tag strip + quote encode, but < > and ' allowed",
  vuln: "reflected-html", delivery: ["query"], note: "script tags are stripped and double quotes entity-encoded, but other tags and single quotes survive")
maze_get "/wafv2/level6/" do |env|
  query = env.params.query.fetch("query", "")
  # Strip <script> and </script> tags (case-insensitive)
  query = query.gsub(/<\/?script[^>]*>/i, "")
  # Encode double quotes
  query = query.gsub("\"", "&quot;")

  "<html><body>#{query}</body></html>"
end
