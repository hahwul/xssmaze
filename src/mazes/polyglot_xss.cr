def load_polyglot_xss
  Xssmaze.push("polyglot-level1", "/polyglot/level1/?query=a", "HTML comment breakout")
  maze_get "/polyglot/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Polyglot XSS Level 1</h1>
    <!-- #{query} -->
    <p>Comment breakout challenge.</p>
    </body></html>"
  end

  Xssmaze.push("polyglot-level2", "/polyglot/level2/?query=a", "meta refresh with URL sink")
  maze_get "/polyglot/level2/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <meta http-equiv=\"refresh\" content=\"0;url=#{query}\">
    </head><body>
    <h1>Polyglot XSS Level 2</h1>
    <p>Meta refresh challenge.</p>
    </body></html>"
  end

  Xssmaze.push("polyglot-level3", "/polyglot/level3/?query=a", "triple URL decode")
  maze_get "/polyglot/level3/" do |env|
    begin
      data = URI.decode(env.params.query["query"])
      data = URI.decode(data)
      if data.includes?("<")
        "Detect Special Character"
      else
        URI.decode(data)
      end
    rescue
      "Decode Error"
    end
  end
end
