def load_multipart_xss
  # Level 1: POST endpoint reflecting filename from multipart form
  Xssmaze.push("multipart-level1", "/multipart/level1/?query=a", "POST reflecting filename from multipart form", "POST", ["filename"])
  maze_get "/multipart/level1/" do |_|
    "<html><body>
    <h1>Multipart XSS Level 1</h1>
    <form action='/multipart/level1/' method='post' enctype='multipart/form-data'>
    <input type='text' name='filename' value='test'>
    <input type='submit'>
    </form>
    </body></html>"
  end
  maze_post "/multipart/level1/" do |env|
    filename = env.params.body.fetch("filename", "test")

    "<html><body>Uploaded: #{filename}</body></html>"
  end

  # Level 2: POST reflecting raw JSON body
  Xssmaze.push("multipart-level2", "/multipart/level2/", "POST reflecting raw JSON body", "POST", ["query"])
  maze_get "/multipart/level2/" do |_|
    "<html><body>
    <h1>Multipart XSS Level 2</h1>
    <button onclick='send()'>run</button>
    <script>
    function send(){
      var xmlhttp = new XMLHttpRequest();
      xmlhttp.open('POST', '/multipart/level2/');
      xmlhttp.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
      xmlhttp.send(JSON.stringify({\"query\":\"a\"}));
    }
    </script>
    </body></html>"
  end
  maze_post "/multipart/level2/" do |env|
    body = env.request.body.try &.gets_to_end || ""

    "<html><body>#{body}</body></html>"
  end

  # Level 3: GET endpoint reflecting Accept header value
  Xssmaze.push("multipart-level3", "/multipart/level3/?query=a", "GET reflecting Accept header in body", "GET", ["query"])
  maze_get "/multipart/level3/" do |env|
    accept = env.request.headers.fetch("Accept", "text/html")

    "<html><body>
    <h1>Multipart XSS Level 3</h1>
    <div>Accept: #{accept}</div>
    </body></html>"
  end

  # Level 4: GET reflecting User-Agent header in body
  Xssmaze.push("multipart-level4", "/multipart/level4/?query=a", "GET reflecting User-Agent header in body")
  maze_get "/multipart/level4/" do |env|
    ua = env.request.headers.fetch("User-Agent", "")

    "<html><body>
    <h1>Multipart XSS Level 4</h1>
    <div>User-Agent: #{ua}</div>
    </body></html>"
  end
end
