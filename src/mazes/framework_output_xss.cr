def load_framework_output_xss
  # Level 1: Django-style error message - raw reflection inside alert div
  Xssmaze.push("fwoutput-level1", "/fwoutput/level1/?query=a", "Django-style error message, raw reflection in alert div")
  maze_get "/fwoutput/level1/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Application Error</title></head>
<body>
<div class=\"container\">
<h1>Error</h1>
<div class=\"alert alert-danger\">Error: #{query}</div>
<p>Please go back and try again.</p>
</div>
</body>
</html>"
  end

  # Level 2: Rails-style search form - reflection in input value attribute (attr breakout)
  Xssmaze.push("fwoutput-level2", "/fwoutput/level2/?query=a", "Rails-style search form, reflection in input value attribute")
  maze_get "/fwoutput/level2/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Search Results</title></head>
<body>
<div class=\"container\">
<h1>Search</h1>
<form action=\"/search\" method=\"get\">
<input id=\"search_field\" name=\"q\" type=\"text\" value=\"#{query}\" class=\"form-control\">
<button type=\"submit\" class=\"btn btn-primary\">Search</button>
</form>
<p>No results found.</p>
</div>
</body>
</html>"
  end

  # Level 3: Express-style JSON error - raw reflection inside <pre> served as text/html
  Xssmaze.push("fwoutput-level3", "/fwoutput/level3/?query=a", "Express-style JSON error in pre tag, served as text/html")
  maze_get "/fwoutput/level3/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Error</title></head>
<body>
<h1>400 Bad Request</h1>
<pre>{\"error\":\"#{query}\",\"status\":400}</pre>
</body>
</html>"
  end

  # Level 4: Spring-style Thymeleaf template - raw reflection in span with th:text
  Xssmaze.push("fwoutput-level4", "/fwoutput/level4/?query=a", "Spring/Thymeleaf-style span, raw reflection in span element")
  maze_get "/fwoutput/level4/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Validation Result</title></head>
<body>
<div class=\"container\">
<h1>Form Validation</h1>
<div class=\"form-group has-error\">
<label>Input:</label>
<span th:text=\"#{query}\" class=\"text-danger\"></span>
</div>
<a href=\"/\">Back to form</a>
</div>
</body>
</html>"
  end

  # Level 5: Laravel-style breadcrumb - raw reflection in breadcrumb item
  Xssmaze.push("fwoutput-level5", "/fwoutput/level5/?query=a", "Laravel-style breadcrumb, raw reflection in breadcrumb item")
  maze_get "/fwoutput/level5/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
<nav aria-label=\"breadcrumb\">
<ol class=\"breadcrumb\">
<li class=\"breadcrumb-item\"><a href=\"/\">Home</a></li>
<li class=\"breadcrumb-item\"><a href=\"/category\">Category</a></li>
<li class=\"breadcrumb-item active\">#{query}</li>
</ol>
</nav>
<div class=\"container\">
<h1>Page Content</h1>
<p>Welcome to the page.</p>
</div>
</body>
</html>"
  end

  # Level 6: .NET-style asp:Label - raw reflection (asp: prefix is just a namespace, doesn't prevent XSS)
  Xssmaze.push("fwoutput-level6", "/fwoutput/level6/?query=a", ".NET-style asp:Label, raw reflection in label element")
  maze_get "/fwoutput/level6/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Server Response</title></head>
<body>
<form id=\"form1\" method=\"post\">
<div class=\"panel panel-default\">
<div class=\"panel-heading\">Server Message</div>
<div class=\"panel-body\">
<asp:Label runat=\"server\">#{query}</asp:Label>
</div>
</div>
</form>
</body>
</html>"
  end
end
