def load_truncation_xss
  # Level 1: Reflects first 100 chars raw - short payloads like <svg/onload=alert(1)> (21 chars) fit easily
  Xssmaze.push("truncation-level1", "/truncation/level1/?query=a", "reflects first 100 chars raw")
  maze_get "/truncation/level1/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 100}.min]
    "<html><body>#{truncated}</body></html>"
  end

  # Level 2: Reflects first 50 chars raw - <img src=x onerror=alert(1)> (30 chars) fits
  Xssmaze.push("truncation-level2", "/truncation/level2/?query=a", "reflects first 50 chars raw")
  maze_get "/truncation/level2/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 50}.min]
    "<html><body>#{truncated}</body></html>"
  end

  # Level 3: Reflects first 200 chars inside input value attribute - break out with " onfocus=alert(1) autofocus "
  Xssmaze.push("truncation-level3", "/truncation/level3/?query=a", "reflects first 200 chars in input value attribute")
  maze_get "/truncation/level3/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 200}.min]
    "<html><body><input type=\"text\" value=\"#{truncated}\"></body></html>"
  end

  # Level 4: Reflects first 30 chars raw - very short payloads like <svg/onload=alert()> (21 chars) fit
  Xssmaze.push("truncation-level4", "/truncation/level4/?query=a", "reflects first 30 chars raw")
  maze_get "/truncation/level4/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 30}.min]
    "<html><body>#{truncated}</body></html>"
  end

  # Level 5: Reflects first 80 chars inside script string - break out with </script><svg/onload=alert(1)> (31 chars)
  Xssmaze.push("truncation-level5", "/truncation/level5/?query=a", "reflects first 80 chars in script string context")
  maze_get "/truncation/level5/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 80}.min]
    "<html><body><script>var x=\"#{truncated}\";</script></body></html>"
  end

  # Level 6: Reflects first 40 chars raw - <img src=x onerror=alert(1)> (30 chars) fits
  Xssmaze.push("truncation-level6", "/truncation/level6/?query=a", "reflects first 40 chars raw")
  maze_get "/truncation/level6/" do |env|
    query = env.params.query["query"]
    truncated = query[0, {query.size, 40}.min]
    "<html><body>#{truncated}</body></html>"
  end
end
