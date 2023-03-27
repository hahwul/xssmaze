def load_redirect
    Xssmaze.push("redirect-level1", "/redirect/level1/","query param")
    get "/redirect/level1/" do |env|
        env.redirect env.params.query["query"]
    end
end