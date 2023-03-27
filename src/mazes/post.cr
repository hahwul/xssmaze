def load_post
    Xssmaze.push("post-level1", "/post/level1/","-x POST -d 'query=a'")
    get "/post/level1/" do |env|
        "<form action='/basic/level2/' method='post'><input type='text' name='query' value='a'><input type='submit'></form>"
    end
    post "/post/level1/" do |env|
        query = env.params.body["query"].as(String)
        "query: #{query}"
    end
end