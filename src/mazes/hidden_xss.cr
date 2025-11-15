def load_hidden_xss
  Xssmaze.push("hidden-xss-level1", "/hidden/level1/?query=a", "input-hidden")
  get "/hidden/level1/" do |env|
    query = env.params.query["query"]

    "<input type=\"hidden=\" value=\"#{query}\">"
  end
  get "/hidden/level1" do |env|
    query = env.params.query["query"]

    "<input type=\"hidden=\" value=\"#{query}\">"
  end

  Xssmaze.push("hidden-xss-level2", "/hidden/level2/?query=a", "input-hidden and escape < >")
  get "/hidden/level2/" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "").gsub(">", "")

    "<input type=\"hidden=\" value=\"#{query}\">"
  end
  get "/hidden/level2" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "").gsub(">", "")

    "<input type=\"hidden=\" value=\"#{query}\">"
  end

  Xssmaze.push("hidden-xss-level3", "/hidden/level3/?query=a", "input-hidden and escape < > and space")
  get "/hidden/level3/" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "").gsub(">", "").gsub(" ", "")

    "<input type=\"hidden=\" value=\"#{query}\">"
  end
  get "/hidden/level3" do |env|
    query = env.params.query["query"]
    query = query.gsub("<", "").gsub(">", "").gsub(" ", "")

    "<input type=\"hidden=\" value=\"#{query}\">"
  end
end
