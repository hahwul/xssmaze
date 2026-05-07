def load_formaction_xss
  Xssmaze.push("formaction-level1", "/formaction/level1/?query=a", "<button formaction> raw reflection")
  maze_get "/formaction/level1/" do |env|
    query = env.params.query["query"]
    "<form action='/echo'><button formaction='#{query}'>submit</button></form>"
  end

  Xssmaze.push("formaction-level2", "/formaction/level2/?query=a", "<input type=image formaction>")
  maze_get "/formaction/level2/" do |env|
    query = env.params.query["query"]
    "<form action='/echo'><input type='image' src='/img.png' formaction='#{query}'></form>"
  end

  Xssmaze.push("formaction-level3", "/formaction/level3/?query=a", "formaction with javascript: blocked literally only")
  maze_get "/formaction/level3/" do |env|
    query = env.params.query["query"].gsub("javascript:", "")
    "<form><button formaction='#{query}'>go</button></form>"
  end

  Xssmaze.push("formaction-level4", "/formaction/level4/?query=a", "form action attribute reflected")
  maze_get "/formaction/level4/" do |env|
    query = env.params.query["query"]
    "<form action='#{query}' method='post'><input name='x'><button>go</button></form>"
  end
end
