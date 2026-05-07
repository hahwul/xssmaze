def load_attrname_xss
  Xssmaze.push("attrname-level1", "/attrname/level1/?query=a", "user controls attribute name on a tag")
  maze_get "/attrname/level1/" do |env|
    query = env.params.query["query"]
    "<div #{query}='value'>hi</div>"
  end

  Xssmaze.push("attrname-level2", "/attrname/level2/?query=a", "attribute name on a button (onclick injection)")
  maze_get "/attrname/level2/" do |env|
    query = env.params.query["query"]
    "<button #{query}='alert(1)'>click</button>"
  end

  Xssmaze.push("attrname-level3", "/attrname/level3/?query=a", "attribute name with space stripped (newline bypass)")
  maze_get "/attrname/level3/" do |env|
    query = env.params.query["query"].gsub(" ", "")
    "<input type='text' #{query}='go'>"
  end

  Xssmaze.push("attrname-level4", "/attrname/level4/?query=a", "attribute name on <a>, equals stripped (boolean attr bypass)")
  maze_get "/attrname/level4/" do |env|
    query = env.params.query["query"].gsub("=", "")
    "<a href='#' #{query}>link</a>"
  end
end
