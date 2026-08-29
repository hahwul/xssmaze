# Level 1: Only `<` encoded to `&lt;` but `>` left raw
# Reflected in body (can't open tags) AND in <input value="QUERY"> where `<` encoding is irrelevant
# Bypass: " onfocus=alert(1) autofocus "
Xssmaze.push("partialencode-level1", "/partial-encode/level1/?query=a", "only < encoded, reflected in input value attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "< is entity-encoded, so the body copy is inert; break out of the double-quoted input value instead")
maze_get "/partial-encode/level1/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.gsub("<", "&lt;")

  "<html><body>#{encoded}<br><input type=\"text\" value=\"#{encoded}\"></body></html>"
end

# Level 2: Only `>` encoded to `&gt;` but `<` left raw
# Reflected in <div title="QUERY"> — `>` is encoded so can't close the tag, but can break attribute
# Bypass: " onfocus=alert(1) x="
Xssmaze.push("partialencode-level2", "/partial-encode/level2/?query=a", "only > encoded, reflected in div title attribute",
  vuln: "reflected-attr", delivery: ["query"], note: "> is entity-encoded, so the tag cannot be closed; break out of the double-quoted title attribute and add an event handler")
maze_get "/partial-encode/level2/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.gsub(">", "&gt;")

  "<html><body><div title=\"#{encoded}\">content</div></body></html>"
end

# Level 3: `"` and `'` encoded but `<>` left raw
# Bypass: <img src=x onerror=alert(1)>
Xssmaze.push("partialencode-level3", "/partial-encode/level3/?query=a", "quotes encoded but angle brackets raw",
  vuln: "reflected-html", delivery: ["query"], note: "both quote characters are encoded but angle brackets are raw; use a quote-free payload")
maze_get "/partial-encode/level3/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.gsub("\"", "&quot;").gsub("'", "&#39;")

  "<html><body>#{encoded}</body></html>"
end

# Level 4: `<script>` and `</script>` tags encoded but nothing else
# Bypass: <img src=x onerror=alert(1)>
Xssmaze.push("partialencode-level4", "/partial-encode/level4/?query=a", "script tags encoded but other tags raw",
  vuln: "reflected-html", delivery: ["query"], note: "only the exact <script> and </script> forms are encoded; <script src=x> or <img src=x onerror=alert(1)> passes")
maze_get "/partial-encode/level4/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.gsub(/<script>/i, "&lt;script&gt;").gsub(/<\/script>/i, "&lt;/script&gt;")

  "<html><body>#{encoded}</body></html>"
end

# Level 5: Only first `<` and first `>` encoded (using .sub not .gsub)
# Bypass: send <> as decoy, then real payload: <><img src=x onerror=alert(1)>
Xssmaze.push("partialencode-level5", "/partial-encode/level5/?query=a", "only first < and > encoded (sub not gsub)",
  vuln: "reflected-html", delivery: ["query"], note: "only the first < and the first > are encoded (sub, not gsub); send a sacrificial <> before the payload")
maze_get "/partial-encode/level5/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.sub("<", "&lt;").sub(">", "&gt;")

  "<html><body>#{encoded}</body></html>"
end

# Level 6: Encodes `&` `"` `'` but leaves `<` `>` raw
# Bypass: <img src=x onerror=alert(1)>
Xssmaze.push("partialencode-level6", "/partial-encode/level6/?query=a", "& and quotes encoded but angle brackets raw",
  vuln: "reflected-html", delivery: ["query"], note: "& is encoded, so an entity-encoded payload will not decode; angle brackets pass through raw")
maze_get "/partial-encode/level6/" do |env|
  query = env.params.query.fetch("query", "")
  encoded = query.gsub("&", "&amp;").gsub("\"", "&quot;").gsub("'", "&#39;")

  "<html><body>#{encoded}</body></html>"
end
