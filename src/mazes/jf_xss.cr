Xssmaze.push("jf-xss-level1", "/jf/level1/?query=a", "escape a-Z",
  vuln: "reflected-js", delivery: ["query"], note: "every ASCII letter is stripped and the value lands as a bare statement inside <script>, so the payload has to be letter-free JavaScript (JSFuck-style []()!+)")
maze_get "/jf/level1/" do |env|
  query = env.params.query["query"]

  "<script>
      #{query.gsub(/[a-zA-Z]/, "")}
    </script>"
end
