def load_basic
    Xssmaze.push("basic-level1", "/basic/level1/?query=a","no escape")
    get "/basic/level1/" do |env|
        env.params.query["query"]
    end

    Xssmaze.push("basic-level2", "/basic/level2/?query=a","escape to double-quot")
    get "/basic/level2/" do |env|
        env.params.query["query"].gsub("\"", "&quot;")
    end

    Xssmaze.push("basic-level3", "/basic/level3/?query=a","escape to single-quot")
    get "/basic/level3/" do |env|
        env.params.query["query"].gsub("'", "&quot;")
    end

    Xssmaze.push("basic-level4", "/basic/level4/?query=a","escape to all quot")
    get "/basic/level4/" do |env|
        env.params.query["query"].gsub("\"", "&quot;").gsub("'","&quot;")
    end

    Xssmaze.push("basic-level5", "/basic/level5/?query=a","escape to parenthesis")
    get "/basic/level5/" do |env|
        env.params.query["query"].gsub("(","").gsub(")","")
    end

    Xssmaze.push("basic-level6", "/basic/level6/?query=a","escape to all quot and parenthesis")
    get "/basic/level6/" do |env|
        env.params.query["query"].gsub("\"", "&quot;").gsub("'","&quot;").gsub("(","").gsub(")","")
    end

    Xssmaze.push("basic-level7", "/basic/level7/?query=a","escape to all quot and parenthesis and backtick")
    get "/basic/level7/" do |env|
        env.params.query["query"].gsub("\"", "&quot;").gsub("'","&quot;").gsub("(","").gsub(")","").gsub("`","")
    end
end