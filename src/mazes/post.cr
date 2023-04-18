def load_post
    Xssmaze.push("post-level1", "/post/level1/","POST-Form => 'query=a'")
    get "/post/level1/" do |env|
        "<form action='/post/level1/' method='post'><input type='text' name='query' value='a'><input type='submit'></form>"
    end
    post "/post/level1/" do |env|
        query = env.params.body["query"].as(String)
        "query: #{query}"
    end

    Xssmaze.push("post-level2", "/post/level2/","POST-Json => {\"query\":\"a\"}")
    get "/post/level2/" do |env|
        "<button onclick=send()>run</button>
         <script>
            function send(){
                var xmlhttp = new XMLHttpRequest();
                xmlhttp.open('POST', '/post/level2/');
                xmlhttp.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
                xmlhttp.send(JSON.stringify({\"query\":\"a\"}));
            }
         </script>"
    end
    post "/post/level2/" do |env|
        query = env.params.json["query"].as(String)
        "query: #{query}"
    end
end