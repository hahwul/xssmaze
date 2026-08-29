# NOTE: srcset/imagesrcset URLs do not by themselves execute JS - the XSS
# in these levels is plain attribute-context injection (the user closes the
# quote and adds onerror=). The category exists so scanners can verify they
# spot reflection inside these specific image-loading attributes.

Xssmaze.push("srcset-level1", "/srcset/level1/?query=a", "attribute-context injection in <img srcset> (multi-candidate)",
  vuln: "reflected-attr", delivery: ["query"], note: "a srcset URL never executes on its own — the bug is the unescaped single-quoted attribute around it")
maze_get "/srcset/level1/" do |env|
  query = env.params.query.fetch("query", "")
  "<img srcset='#{query}'>"
end

Xssmaze.push("srcset-level2", "/srcset/level2/?query=a", "attribute-context injection in <source srcset> inside <picture>",
  vuln: "reflected-attr", delivery: ["query"])
maze_get "/srcset/level2/" do |env|
  query = env.params.query.fetch("query", "")
  "<picture><source srcset='#{query}'><img src='/fallback.png'></picture>"
end

Xssmaze.push("srcset-level3", "/srcset/level3/?query=a", "attribute-context injection with comma stripped (descriptor bypass)",
  vuln: "reflected-attr", delivery: ["query"], note: "commas are stripped and a \" 1x\" descriptor is appended after the reflection")
maze_get "/srcset/level3/" do |env|
  query = env.params.query.fetch("query", "").gsub(",", "")
  "<img srcset='#{query} 1x'>"
end

Xssmaze.push("srcset-level4", "/srcset/level4/?query=a", "attribute-context injection on <link rel=preload imagesrcset>",
  vuln: "reflected-attr", delivery: ["query"])
maze_get "/srcset/level4/" do |env|
  query = env.params.query.fetch("query", "")
  "<link rel='preload' as='image' imagesrcset='#{query}'>"
end
