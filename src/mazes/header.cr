def load_header
  Xssmaze.push("header-level1", "/header/level1/", "referer header")
  get "/header/level1/" do |env|
    env.response.headers["referer"]
  end
  get "/header/level1" do |env|
    env.response.headers["referer"]
  end

  Xssmaze.push("header-level2", "/header/level2/", "user-agent header")
  get "/header/level2/" do |env|
    env.response.headers["user-agent"]
  end
  get "/header/level2" do |env|
    env.response.headers["user-agent"]
  end

  Xssmaze.push("header-level3", "/header/level3/", "authorization header")
  get "/header/level3/" do |env|
    env.response.headers["authorization"]
  end
  get "/header/level3" do |env|
    env.response.headers["authorization"]
  end

  Xssmaze.push("header-level4", "/header/level4/", "cookie header")
  get "/header/level4/" do |env|
    env.response.headers["cookie"]
  end
  get "/header/level4" do |env|
    env.response.headers["cookie"]
  end
end
