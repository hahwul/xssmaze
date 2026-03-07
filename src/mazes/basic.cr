def load_basic
  Xssmaze.push("basic-level1", "/basic/level1/?query=a", "no escape")
  maze_get "/basic/level1/" do |env|
    env.params.query["query"]
  end

  Xssmaze.push("basic-level2", "/basic/level2/?query=a", "escape to double-quot")
  maze_get "/basic/level2/" do |env|
    Filters.escape_double_quote(env.params.query["query"])
  end

  Xssmaze.push("basic-level3", "/basic/level3/?query=a", "escape to single-quot")
  maze_get "/basic/level3/" do |env|
    Filters.escape_single_quote(env.params.query["query"])
  end

  Xssmaze.push("basic-level4", "/basic/level4/?query=a", "escape to all quot")
  maze_get "/basic/level4/" do |env|
    Filters.escape_quotes(env.params.query["query"])
  end

  Xssmaze.push("basic-level5", "/basic/level5/?query=a", "escape to parenthesis")
  maze_get "/basic/level5/" do |env|
    Filters.strip_parens(env.params.query["query"])
  end

  Xssmaze.push("basic-level6", "/basic/level6/?query=a", "escape to all quot and parenthesis")
  maze_get "/basic/level6/" do |env|
    query = Filters.escape_quotes(env.params.query["query"])
    Filters.strip_parens(query)
  end

  Xssmaze.push("basic-level7", "/basic/level7/?query=a", "escape to all quot and parenthesis and backtick")
  maze_get "/basic/level7/" do |env|
    query = Filters.escape_quotes(env.params.query["query"])
    query = Filters.strip_parens(query)
    query.gsub("`", "")
  end
end
