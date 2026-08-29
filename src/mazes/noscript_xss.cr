Xssmaze.push("noscript-level1", "/noscript/level1/?query=a", "raw reflection inside <noscript>",
  vuln: "reflected-html", delivery: ["query"], note: "with scripting enabled a browser parses <noscript> content as raw text, so the payload must open with </noscript> before any tag is recognised")
maze_get "/noscript/level1/" do |env|
  query = env.params.query["query"]
  "<noscript>#{query}</noscript>"
end

Xssmaze.push("noscript-level2", "/noscript/level2/?query=a", "noscript content fed back to innerHTML by client JS",
  vuln: "dom", sources: ["textContent"], sinks: ["innerHTML"], delivery: ["query"], note: "the raw-text <noscript> body is relayed into innerHTML, so no </noscript> breakout is needed; innerHTML does not run a bare <script>, so use <img src=x onerror=...>")
maze_get "/noscript/level2/" do |env|
  query = env.params.query["query"]
  "<noscript id='ns'>#{query}</noscript>
   <div id='out'></div>
   <script>
     document.getElementById('out').innerHTML = document.getElementById('ns').textContent;
   </script>"
end

Xssmaze.push("noscript-level3", "/noscript/level3/?query=a", "<noscript> stripped only literally; nested case bypass",
  vuln: "reflected-html", delivery: ["query"], note: "only the exact lowercase <noscript> and </noscript> strings are stripped, and only once, so </NOSCRIPT> or </nos</noscript>cript> gets out of the raw-text element")
maze_get "/noscript/level3/" do |env|
  query = env.params.query["query"].gsub("<noscript>", "").gsub("</noscript>", "")
  "<noscript>#{query}</noscript>"
end

Xssmaze.push("noscript-level4", "/noscript/level4/?query=a", "<noscript> with reflected attribute on inner <meta>",
  vuln: "reflected-html", delivery: ["query"], note: "with scripting enabled the <meta> is never a real element (it sits in <noscript> raw text) and a meta refresh to javascript: does not execute anyway; close </noscript> and inject a tag")
maze_get "/noscript/level4/" do |env|
  query = env.params.query["query"]
  "<noscript><meta http-equiv='refresh' content='0;url=#{query}'></noscript>"
end
