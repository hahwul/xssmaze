def load_injs_xss
  Xssmaze.push("injs-xss-level1", "/injs/level1/?query=a", "injs-xss")
  get "/injs/level1/" do |env|
    query = env.params.query["query"]

    "<script>
        var data = #{query};
    </script>"
  end

  Xssmaze.push("injs-xss-level2", "/injs/level2/?query=a", "injs-xss - in single quote")
  get "/injs/level2/" do |env|
    query = env.params.query["query"]

    "<script>
        var data = '#{query}';
    </script>"
  end

  Xssmaze.push("injs-xss-level3", "/injs/level3/?query=a", "injs-xss - in double quote")
  get "/injs/level3/" do |env|
    query = env.params.query["query"]

    "<script>
        var data = \"#{query}\";
    </script>"
  end

  Xssmaze.push("injs-xss-level4", "/injs/level4/?query=a", "injs-xss - in single quote and double quote")
  get "/injs/level4/" do |env|
    query = env.params.query["query"].gsub("'", "")

    "<script>
        var data = '#{query}' // this is '#{query}';
    </script>"
  end
end
