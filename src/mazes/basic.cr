def load_basic
    Xssmaze.push("basic-level1", "/basic/level1/?query=a","")
    Xssmaze.push("basic-level2", "/basic/level2/","-x POST -d 'query=a'")
    Xssmaze.push("basic-level3", "/basic/level3/a","")

    get "/basic/level1/" do |env|
        env.params.query["query"]
    end
    get "/basic/level2/" do |env|
        "<form action='/basic/level2/' method='post'><input type='text' name='query' value='a'><input type='submit'></form>"
    end
    post "/basic/level2/" do |env|
        query = env.params.body["query"].as(String)
        "query: #{query}"
    end
    get "/basic/level3/:name" do |env|
        name = env.params.url["name"]
        "Hi #{name}"
    end
end