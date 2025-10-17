def load_jf_xss
  Xssmaze.push("jf-xss-level1", "/jf/level1/?query=a", "escape a-Z", "jf-xss")
  get "/jf/level1/" do |env|
    query = env.params.query["query"]

    "<script>
        #{query.gsub(/[a-zA-Z]/, "")}
      </script>"
  end
end
