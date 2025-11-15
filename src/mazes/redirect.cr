def load_redirect
  Xssmaze.push("redirect-level1", "/redirect/level1/", "query param")
  get "/redirect/level1/" do |env|
    env.redirect env.params.query["query"]
  end
  get "/redirect/level1" do |env|
    env.redirect env.params.query["query"]
  end

  Xssmaze.push("redirect-level2", "/redirect/level2/", "query param")
  get "/redirect/level2/" do |env|
    env.redirect env.params.query["query"].gsub("javascript", "")
  end
  get "/redirect/level2" do |env|
    env.redirect env.params.query["query"].gsub("javascript", "")
  end

  Xssmaze.push("redirect-level3", "/redirect/level3/", "query param")
  get "/redirect/level3/" do |env|
    env.redirect env.params.query["query"].downcase.gsub("javascript", "")
  end
  get "/redirect/level3" do |env|
    env.redirect env.params.query["query"].downcase.gsub("javascript", "")
  end

  Xssmaze.push("redirect-level4", "/redirect/level4/", "query param")
  get "/redirect/level4/" do |env|
    env.redirect env.params.query["query"].downcase.gsub("javascript", "").downcase.gsub("javascript", "")
  end
  get "/redirect/level4" do |env|
    env.redirect env.params.query["query"].downcase.gsub("javascript", "").downcase.gsub("javascript", "")
  end
end
