def load_path
  Xssmaze.push("path-level1", "/path/level1/a", "reflected", "path")
  get "/path/level1/:name" do |env|
    name = env.params.url["name"]
    "Hi #{name}"
  end

  Xssmaze.push("path-level2", "/path/level2/a", "escape to %2f", "path")
  get "/path/level2/:name" do |env|
    name = env.params.url["name"].gsub("%2f", "")
    "Hi #{name}"
  end

  Xssmaze.push("path-level3", "/path/level3/a", "escape to %20", "path")
  get "/path/level3/:name" do |env|
    name = env.params.url["name"].gsub(" ", "").gsub("%20", "")
    "Hi #{name}"
  end

  Xssmaze.push("path-level4", "/path/level4/a", "escape to %2f and %20", "path")
  get "/path/level4/:name" do |env|
    name = env.params.url["name"].gsub("%2f", "").gsub("%20", "")
    "Hi #{name}"
  end
end
