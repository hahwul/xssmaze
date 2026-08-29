Xssmaze.push("mathml-level1", "/mathml/level1/?query=a", "MathML mtext raw reflection (parser context)",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw inside MathML <mtext>; browser MathML parsing enables sanitizer-bypass vectors")
maze_get "/mathml/level1/" do |env|
  query = env.params.query["query"]
  "<math><mtext>#{query}</mtext></math>"
end

Xssmaze.push("mathml-level2", "/mathml/level2/?query=a", "MathML annotation-xml encoding=text/html (HTML-in-MathML parser quirk)",
  vuln: "reflected-html", delivery: ["query"], note: "script removed once and case-sensitively; annotation-xml encoding=text/html is an HTML integration point, so injected markup is parsed as HTML")
maze_get "/mathml/level2/" do |env|
  query = env.params.query["query"].gsub("script", "")
  "<math>
     <semantics>
       <annotation-xml encoding='text/html'>#{query}</annotation-xml>
     </semantics>
   </math>"
end

Xssmaze.push("mathml-level3", "/mathml/level3/?query=a", "MathML mglyph nested in mtext (HTML5 sanitizer-bypass quirk)",
  vuln: "reflected-attr", delivery: ["query"], note: "reflected into a single-quoted mglyph src; break out of the value")
maze_get "/mathml/level3/" do |env|
  query = env.params.query["query"]
  "<math><mtext><mglyph src='#{query}'></mglyph></mtext></math>"
end
