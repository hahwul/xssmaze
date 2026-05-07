def load_dataurl_xss
  Xssmaze.push("dataurl-level1", "/dataurl/level1/?query=a", "anchor href with data:text/html under user control (executes on click)")
  maze_get "/dataurl/level1/" do |env|
    query = env.params.query["query"]
    "<a href='data:text/html,#{query}'>open</a>"
  end

  Xssmaze.push("dataurl-level2", "/dataurl/level2/?query=a", "iframe src=data:text/html with reflected body")
  maze_get "/dataurl/level2/" do |env|
    query = env.params.query["query"]
    "<iframe src='data:text/html;charset=utf-8,#{query}'></iframe>"
  end

  Xssmaze.push("dataurl-level3", "/dataurl/level3/?query=a", "object data=data:text/html with reflected payload")
  maze_get "/dataurl/level3/" do |env|
    query = env.params.query["query"]
    "<object data='data:text/html,#{query}'></object>"
  end

  Xssmaze.push("dataurl-level4", "/dataurl/level4/?query=a", "embed src=data:text/html with reflected payload")
  maze_get "/dataurl/level4/" do |env|
    query = env.params.query["query"]
    "<embed src='data:text/html,#{query}'>"
  end
end
