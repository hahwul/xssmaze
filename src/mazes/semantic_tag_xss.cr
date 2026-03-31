def load_semantic_tag_xss
  # Level 1: Reflected in <article><p>QUERY</p></article>
  Xssmaze.push("semantictag-level1", "/semantictag/level1/?query=a", "reflection in article > p element")
  maze_get "/semantictag/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 1</h1>
    <article><p>#{query}</p></article>
    </body></html>"
  end

  # Level 2: Reflected in <section><h2>QUERY</h2></section>
  Xssmaze.push("semantictag-level2", "/semantictag/level2/?query=a", "reflection in section > h2 element")
  maze_get "/semantictag/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 2</h1>
    <section><h2>#{query}</h2></section>
    </body></html>"
  end

  # Level 3: Reflected in <aside>QUERY</aside>
  Xssmaze.push("semantictag-level3", "/semantictag/level3/?query=a", "reflection in aside element")
  maze_get "/semantictag/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 3</h1>
    <aside>#{query}</aside>
    </body></html>"
  end

  # Level 4: Reflected in <nav><a href="#">QUERY</a></nav>
  Xssmaze.push("semantictag-level4", "/semantictag/level4/?query=a", "reflection in nav > a link text")
  maze_get "/semantictag/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 4</h1>
    <nav><a href=\"#\">#{query}</a></nav>
    </body></html>"
  end

  # Level 5: Reflected in <footer>QUERY</footer>
  Xssmaze.push("semantictag-level5", "/semantictag/level5/?query=a", "reflection in footer element")
  maze_get "/semantictag/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 5</h1>
    <footer>#{query}</footer>
    </body></html>"
  end

  # Level 6: Reflected in <main><blockquote>QUERY</blockquote></main>
  Xssmaze.push("semantictag-level6", "/semantictag/level6/?query=a", "reflection in main > blockquote element")
  maze_get "/semantictag/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Semantic Tag XSS Level 6</h1>
    <main><blockquote>#{query}</blockquote></main>
    </body></html>"
  end
end
