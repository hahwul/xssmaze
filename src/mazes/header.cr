def load_header
    Xssmaze.push("header-level1", "/header/level1/","referer header")
    get "/header/level1/" do |env|
        env.response.headers["referer"]
    end
end