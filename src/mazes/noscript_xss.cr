def load_noscript_xss
  Xssmaze.push("noscript-level1", "/noscript/level1/?query=a", "raw reflection inside <noscript>")
  maze_get "/noscript/level1/" do |env|
    query = env.params.query["query"]
    "<noscript>#{query}</noscript>"
  end

  Xssmaze.push("noscript-level2", "/noscript/level2/?query=a", "noscript content fed back to innerHTML by client JS")
  maze_get "/noscript/level2/" do |env|
    query = env.params.query["query"]
    "<noscript id='ns'>#{query}</noscript>
     <div id='out'></div>
     <script>
       document.getElementById('out').innerHTML = document.getElementById('ns').textContent;
     </script>"
  end

  Xssmaze.push("noscript-level3", "/noscript/level3/?query=a", "<noscript> stripped only literally; nested case bypass")
  maze_get "/noscript/level3/" do |env|
    query = env.params.query["query"].gsub("<noscript>", "").gsub("</noscript>", "")
    "<noscript>#{query}</noscript>"
  end

  Xssmaze.push("noscript-level4", "/noscript/level4/?query=a", "<noscript> with reflected attribute on inner <meta>")
  maze_get "/noscript/level4/" do |env|
    query = env.params.query["query"]
    "<noscript><meta http-equiv='refresh' content='0;url=#{query}'></noscript>"
  end
end
