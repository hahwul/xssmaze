def load_header
  Xssmaze.push("header-level1", "/header/level1/", "referer header", "header")
  get "/header/level1/" do |env|
    env.response.headers["referer"]
  end

  Xssmaze.push("header-level2", "/header/level2/", "user-agent header", "header")
  get "/header/level2/" do |env|
    env.response.headers["user-agent"]
  end

  Xssmaze.push("header-level3", "/header/level3/", "authorization header", "header")
  get "/header/level3/" do |env|
    env.response.headers["authorization"]
  end

  Xssmaze.push("header-level4", "/header/level4/", "cookie header", "header")
  get "/header/level4/" do |env|
    env.response.headers["cookie"]
  end
end
