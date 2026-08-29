# Level 1: JS double-quoted string with " escaped to \" but </script> not blocked
# Bypass: can't break out of JS string with ", but can close the script tag
# e.g. </script><script>alert(1)</script>
Xssmaze.push("jsescape-level1", "/jsescape/level1/?query=a", "JS string double-quote escaped but script tag not blocked",
  vuln: "reflected-js", delivery: ["query"], note: "double quotes are backslash-escaped; close the <script> block instead of the string")
maze_get "/jsescape/level1/" do |env|
  query = env.params.query.fetch("query", "").gsub("\"", "\\\"")

  "<html><body><script>var msg = \"#{query}\";</script></body></html>"
end

# Level 2: JS single-quoted string with ' escaped to \' but </script> not blocked
# Bypass: can't break out of JS string with ', but can close the script tag
# e.g. </script><script>alert(1)</script>
Xssmaze.push("jsescape-level2", "/jsescape/level2/?query=a", "JS string single-quote escaped but script tag not blocked",
  vuln: "reflected-js", delivery: ["query"], note: "the backslash itself is not escaped, so a leading backslash neutralises the quote escape and closes the string; closing the <script> block also works")
maze_get "/jsescape/level2/" do |env|
  query = env.params.query.fetch("query", "").gsub("'", "\\'")

  "<html><body><script>var msg = '#{query}';</script></body></html>"
end

# Level 3: JS template literal with " and ' escaped, but backtick not escaped, </script> not blocked
# Bypass: close script tag and inject HTML
# e.g. </script><script>alert(1)</script>
Xssmaze.push("jsescape-level3", "/jsescape/level3/?query=a", "JS template literal quotes escaped but backtick and script tag not blocked",
  vuln: "reflected-js", delivery: ["query"], note: "template literal: the backtick is not escaped, and a ${...} substitution evaluates without any breakout")
maze_get "/jsescape/level3/" do |env|
  query = env.params.query.fetch("query", "").gsub("\"", "\\\"").gsub("'", "\\'")

  "<html><body><script>var msg = `#{query}`;</script></body></html>"
end

# Level 4: JS double-quoted string with \ escaped to \\ and " escaped to \"
# Bypass: input \" — after \ escape: \\" — after " escape: \\\" — wait, that's still escaped
# Actually, since \ is escaped to \\, input \" becomes \\" after \ escape, then
# the " in \\" is escaped to \\\" — still safe.
# Real vulnerability: just close script tag (</script> is not blocked, and neither
# \ nor " escaping affects angle brackets)
# e.g. </script><script>alert(1)</script>
Xssmaze.push("jsescape-level4", "/jsescape/level4/?query=a", "JS string with backslash and quote both escaped but script tag not blocked",
  vuln: "reflected-js", delivery: ["query"], note: "backslashes are escaped before quotes, so the string itself holds; close the <script> block")
maze_get "/jsescape/level4/" do |env|
  query = env.params.query.fetch("query", "")
  query = query.gsub("\\", "\\\\") # \ -> \\
  query = query.gsub("\"", "\\\"") # " -> \"

  "<html><body><script>var msg = \"#{query}\";</script></body></html>"
end

# Level 5: Dual reflection - JS string has < encoded to \x3c (preventing </script>),
# but query is also reflected raw in the HTML body
# Bypass: exploit the body reflection with raw HTML injection
# e.g. <script>alert(1)</script>
Xssmaze.push("jsescape-level5", "/jsescape/level5/?query=a", "JS string with < encoded but raw reflection in body",
  vuln: "reflected-html", delivery: ["query"], note: "the script-string copy encodes < and the quote, but the same value is reflected raw into the div just after it")
maze_get "/jsescape/level5/" do |env|
  query = env.params.query.fetch("query", "")
  js_query = query.gsub("<", "\\x3c").gsub("\"", "\\\"")

  "<html><body><script>var msg = \"#{js_query}\";</script><div>Search: #{query}</div></body></html>"
end

# Level 6: JS single-quoted string with ' escaped to &#39; (HTML entity in JS context)
# The HTML entity &#39; does NOT function as a JS escape - it's literal text in JS
# Bypass: close script tag (</script> not blocked)
# e.g. </script><script>alert(1)</script>
Xssmaze.push("jsescape-level6", "/jsescape/level6/?query=a", "JS string single-quote HTML-entity escaped (ineffective in JS)",
  vuln: "reflected-js", delivery: ["query"], note: "quotes are replaced with an HTML entity, which is literal text inside a script element and never decodes; close the <script> block")
maze_get "/jsescape/level6/" do |env|
  query = env.params.query.fetch("query", "").gsub("'", "&#39;")

  "<html><body><script>var msg = '#{query}';</script></body></html>"
end
