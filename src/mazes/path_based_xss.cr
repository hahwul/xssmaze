def load_path_based_xss
  # Level 1: Query reflected in page breadcrumb-style paragraph
  Xssmaze.push("pathxss-level1", "/pathxss/level1/?query=a", "query reflected in body paragraph")
  maze_get "/pathxss/level1/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Page</title></head>
<body><p>Page: #{query}</p></body></html>"
  end

  # Level 2: Query reflected in breadcrumb navigation
  Xssmaze.push("pathxss-level2", "/pathxss/level2/?query=a", "query reflected in breadcrumb navigation")
  maze_get "/pathxss/level2/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Breadcrumb</title></head>
<body><nav>Home > #{query}</nav>
<p>Welcome to this page.</p></body></html>"
  end

  # Level 3: Query reflected in <title> tag - break out with </title>
  Xssmaze.push("pathxss-level3", "/pathxss/level3/?query=a", "query reflected in title tag")
  maze_get "/pathxss/level3/" do |env|
    query = env.params.query["query"]

    "<html><head><title>#{query} - Site</title></head>
<body><p>Content</p></body></html>"
  end

  # Level 4: Query reflected in canonical link href - break out with "
  Xssmaze.push("pathxss-level4", "/pathxss/level4/?query=a", "query reflected in canonical link href attribute")
  maze_get "/pathxss/level4/" do |env|
    query = env.params.query["query"]

    "<html><head>
<link rel=\"canonical\" href=\"/page/#{query}\">
<title>Canonical</title></head>
<body><p>Content</p></body></html>"
  end

  # Level 5: Query reflected in body AND in JS variable
  Xssmaze.push("pathxss-level5", "/pathxss/level5/?query=a", "query reflected in body and JS variable")
  maze_get "/pathxss/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Dual Reflection</title></head>
<body><p>Page: #{query}</p>
<script>var page=\"#{query}\";</script>
</body></html>"
  end

  # Level 6: Query reflected raw in <h1>
  Xssmaze.push("pathxss-level6", "/pathxss/level6/?query=a", "query reflected raw in h1 tag")
  maze_get "/pathxss/level6/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Raw Reflection</title></head>
<body><h1>#{query}</h1></body></html>"
  end
end
