def load_inattr_xss
  Xssmaze.push("inattr-xss-level1", "/inattr/level1/?query=a", "inattr-xss (double quote)", "inattr-xss")
  get "/inattr/level1/" do |env|
    query = env.params.query["query"]

    "<div class=\"#{query}\">Hello</div>"
  end

  Xssmaze.push("inattr-xss-level2", "/inattr/level2/?query=a", "inattr-xss (single quote)", "inattr-xss")
  get "/inattr/level2/" do |env|
    query = env.params.query["query"]

    "<div class='#{query}'>Hello</div>"
  end

  Xssmaze.push("inattr-xss-level3", "/inattr/level3/?query=a", "inattr-xss (double quote with <> filter)", "inattr-xss")
  get "/inattr/level3/" do |env|
    query = env.params.query["query"]

    "<div class=\"#{query.gsub("<", "").gsub(">", "")}\">Hello</div>"
  end

  Xssmaze.push("inattr-xss-level4", "/inattr/level4/?query=a", "inattr-xss (single quote with <> filter)", "inattr-xss")
  get "/inattr/level4/" do |env|
    query = env.params.query["query"]

    "<div class='#{query.gsub("<", "").gsub(">", "")}'>Hello</div>"
  end

  Xssmaze.push("inattr-xss-level5", "/inattr/level5/?query=a", "inattr-xss (double quote with <> and blank filter)", "inattr-xss")
  get "/inattr/level5/" do |env|
    query = env.params.query["query"]

    "<div class=\"#{query.gsub("<", "").gsub(">", "").gsub(" ", "")}\">Hello</div>"
  end

  Xssmaze.push("inattr-xss-level6", "/inattr/level6/?query=a", "inattr-xss (single quote with <> and blank filter)", "inattr-xss")
  get "/inattr/level6/" do |env|
    query = env.params.query["query"]

    "<div class='#{query.gsub("<", "").gsub(">", "").gsub(" ", "")}'>Hello</div>"
  end
end
