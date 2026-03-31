def load_prototype_xss
  # Level 1: WordPress-style settings form — attribute breakout from input value
  Xssmaze.push("prototype-pattern-level1", "/prototype-pattern/level1/?query=a", "WordPress-style input value reflection")
  maze_get "/prototype-pattern/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
<div class=\"wrap\">
<h1>General Settings</h1>
<form method=\"post\" action=\"options.php\">
<table class=\"form-table\">
<tr><th scope=\"row\"><label for=\"blogname\">Site Title</label></th>
<td><input type=\"text\" class=\"regular-text\" id=\"blogname\" name=\"blogname\" value=\"#{query}\" /></td>
</tr></table>
</form></div></body></html>"
  end

  # Level 2: PHP error-style — raw HTML injection in error message
  Xssmaze.push("prototype-pattern-level2", "/prototype-pattern/level2/?query=a", "PHP error message reflection (raw injection)")
  maze_get "/prototype-pattern/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
<br />
<b>Warning</b>: Undefined variable: #{query} in <b>/var/www/html/index.php</b> on line <b>42</b>
<br />
</body></html>"
  end

  # Level 3: ASP.NET-style error label — raw HTML injection in span
  Xssmaze.push("prototype-pattern-level3", "/prototype-pattern/level3/?query=a", "ASP.NET-style error label reflection")
  maze_get "/prototype-pattern/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
<form method=\"post\" action=\"./Default.aspx\" id=\"form1\">
<div class=\"aspNetHidden\">
<input type=\"hidden\" name=\"__VIEWSTATE\" value=\"/wEPDw==\" />
</div>
<div id=\"content\">
<h2>Error</h2>
<span id=\"ctl00_ContentPlaceHolder1_lblError\">#{query}</span>
</div>
</form></body></html>"
  end

  # Level 4: Angular-style template — raw HTML injection (server-side rendered)
  Xssmaze.push("prototype-pattern-level4", "/prototype-pattern/level4/?query=a", "Angular-style ng-app reflection (raw injection)")
  maze_get "/prototype-pattern/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
<div ng-app=\"myApp\" ng-controller=\"myCtrl\">
<div class=\"container\">
<h2>Search Results</h2>
<p>#{query}</p>
</div>
</div>
</body></html>"
  end

  # Level 5: React-style server-rendered — raw HTML injection in data-reactroot div
  Xssmaze.push("prototype-pattern-level5", "/prototype-pattern/level5/?query=a", "React-style server-rendered reflection (raw injection)")
  maze_get "/prototype-pattern/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
<div id=\"root\"><div data-reactroot=\"\"><div class=\"App\"><header class=\"App-header\"><h1>Welcome</h1><p>#{query}</p></header></div></div></div>
<script src=\"/static/js/bundle.js\"></script>
</body></html>"
  end

  # Level 6: Flask/Jinja-style — no template escaping, raw injection in welcome message
  Xssmaze.push("prototype-pattern-level6", "/prototype-pattern/level6/?query=a", "Flask/Jinja-style unescaped reflection")
  maze_get "/prototype-pattern/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
<nav class=\"navbar\"><a class=\"brand\" href=\"/\">MyApp</a></nav>
<div class=\"container\">
<h1>Dashboard</h1>
<p>Welcome, #{query}!</p>
<p>You have 3 new notifications.</p>
</div>
</body></html>"
  end
end
