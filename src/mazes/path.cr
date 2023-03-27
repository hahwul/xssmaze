def load_path
    Xssmaze.push("path-level1", "/path/level3/a","")
    get "/path/level1/:name" do |env|
        name = env.params.url["name"]
        "Hi #{name}"
    end
end