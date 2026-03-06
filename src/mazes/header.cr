def load_header
  Xssmaze.push("header-level1", "/header/level1/", "referer header")
  get "/header/level1/" do |env|
    env.request.headers["Referer"]? || ""
  end
  get "/header/level1" do |env|
    env.request.headers["Referer"]? || ""
  end

  Xssmaze.push("header-level2", "/header/level2/", "user-agent header")
  get "/header/level2/" do |env|
    env.request.headers["User-Agent"]? || ""
  end
  get "/header/level2" do |env|
    env.request.headers["User-Agent"]? || ""
  end

  Xssmaze.push("header-level3", "/header/level3/", "authorization header")
  get "/header/level3/" do |env|
    env.request.headers["Authorization"]? || ""
  end
  get "/header/level3" do |env|
    env.request.headers["Authorization"]? || ""
  end

  Xssmaze.push("header-level4", "/header/level4/", "cookie header")
  get "/header/level4/" do |env|
    env.request.headers["Cookie"]? || ""
  end
  get "/header/level4" do |env|
    env.request.headers["Cookie"]? || ""
  end
end
