def load_mathml_xss
  Xssmaze.push("mathml-level1", "/mathml/level1/?query=a", "MathML mtext raw reflection (parser context)")
  maze_get "/mathml/level1/" do |env|
    query = env.params.query["query"]
    "<math><mtext>#{query}</mtext></math>"
  end

  Xssmaze.push("mathml-level2", "/mathml/level2/?query=a", "MathML annotation-xml encoding=text/html (HTML-in-MathML parser quirk)")
  maze_get "/mathml/level2/" do |env|
    query = env.params.query["query"].gsub("script", "")
    "<math>
       <semantics>
         <annotation-xml encoding='text/html'>#{query}</annotation-xml>
       </semantics>
     </math>"
  end

  Xssmaze.push("mathml-level3", "/mathml/level3/?query=a", "MathML mglyph nested in mtext (HTML5 sanitizer-bypass quirk)")
  maze_get "/mathml/level3/" do |env|
    query = env.params.query["query"]
    "<math><mtext><mglyph src='#{query}'></mglyph></mtext></math>"
  end
end
