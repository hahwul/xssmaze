def load_redirect
    Xssmaze.push("redirect-level1", "/redirect/level1/","query param")
    get "/redirect/level1/" do |env|
        env.redirect env.params.query["query"]
    end
    
    Xssmaze.push("redirect-level2", "/redirect/level2/","query param")
    get "/redirect/level2/" do |env|
        env.redirect env.params.query["query"].gsub("javascript","")
    end

    Xssmaze.push("redirect-level2", "/redirect/level3/","query param")
    get "/redirect/level3/" do |env|
        env.redirect env.params.query["query"].downcase.gsub("javascript","")
    end
end