def load_multi_vector_xss
  # Level 1: Page has 3 forms, query reflected only in 2nd form's input value
  # Scanner needs to identify the correct reflection point among multiple forms
  Xssmaze.push("multivector-level1", "/multivector/level1/?query=a", "3 forms, reflection in 2nd form input value only")
  maze_get "/multivector/level1/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html><body>
<h1>Multi-Form Page</h1>
<form id=\"form1\" action=\"/search\" method=\"get\">
<input type=\"text\" name=\"q\" value=\"default1\">
<button type=\"submit\">Search</button>
</form>
<form id=\"form2\" action=\"/filter\" method=\"get\">
<input type=\"text\" name=\"filter\" value=\"#{query}\">
<button type=\"submit\">Filter</button>
</form>
<form id=\"form3\" action=\"/sort\" method=\"get\">
<input type=\"text\" name=\"sort\" value=\"default3\">
<button type=\"submit\">Sort</button>
</form>
</body></html>"
  end

  # Level 2: Query reflected in both script context AND HTML body
  # Two exploitable vectors on same page — scanner should find at least one
  Xssmaze.push("multivector-level2", "/multivector/level2/?query=a", "dual reflection: script var + HTML body paragraph")
  maze_get "/multivector/level2/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html><body>
<script>var x = \"#{query}\";</script>
<h1>Welcome</h1>
<p>Your search: #{query}</p>
</body></html>"
  end

  # Level 3: Query reflected in <option value=""> inside a <select> with 10 options
  # Must break out of option/select context
  Xssmaze.push("multivector-level3", "/multivector/level3/?query=a", "reflection in option value inside select with 10 options")
  maze_get "/multivector/level3/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html><body>
<h1>Choose an Option</h1>
<select name=\"choice\" id=\"choices\">
<option value=\"opt1\">Option 1</option>
<option value=\"opt2\">Option 2</option>
<option value=\"opt3\">Option 3</option>
<option value=\"#{query}\">Custom Option</option>
<option value=\"opt5\">Option 5</option>
<option value=\"opt6\">Option 6</option>
<option value=\"opt7\">Option 7</option>
<option value=\"opt8\">Option 8</option>
<option value=\"opt9\">Option 9</option>
<option value=\"opt10\">Option 10</option>
</select>
</body></html>"
  end

  # Level 4: Page has 5 input fields, query reflected only in the 3rd field's value
  # Scanner must identify the correct injection point among many inputs
  Xssmaze.push("multivector-level4", "/multivector/level4/?query=a", "5 input fields, reflection only in 3rd field value")
  maze_get "/multivector/level4/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html><body>
<h1>User Profile</h1>
<form>
<div><label>First Name:</label><input type=\"text\" name=\"fname\" value=\"John\"></div>
<div><label>Last Name:</label><input type=\"text\" name=\"lname\" value=\"Doe\"></div>
<div><label>Nickname:</label><input type=\"text\" name=\"nick\" value=\"#{query}\"></div>
<div><label>Email:</label><input type=\"email\" name=\"email\" value=\"user@example.com\"></div>
<div><label>Phone:</label><input type=\"tel\" name=\"phone\" value=\"555-0100\"></div>
<button type=\"submit\">Save</button>
</form>
</body></html>"
  end

  # Level 5: Triple reflection — query in <title>, <meta content>, and <div>
  # All three contexts are exploitable in different ways
  Xssmaze.push("multivector-level5", "/multivector/level5/?query=a", "triple reflection: title + meta content + div body")
  maze_get "/multivector/level5/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html>
<head>
<meta charset=\"UTF-8\">
<title>#{query}</title>
<meta name=\"description\" content=\"#{query}\">
</head>
<body>
<h1>Page Title</h1>
<div class=\"content\">#{query}</div>
</body></html>"
  end

  # Level 6: Complex page structure — query buried deep in nested article>section>div>p
  # Scanner must handle deeply nested DOM to find the reflection
  Xssmaze.push("multivector-level6", "/multivector/level6/?query=a", "deep nested reflection: article > section > div > p")
  maze_get "/multivector/level6/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\">
<title>News Portal</title>
<style>
body { font-family: Arial, sans-serif; margin: 0; }
.topbar { background: #1a1a2e; color: white; padding: 10px 20px; }
.nav { background: #16213e; padding: 8px 20px; }
.nav a { color: #e2e2e2; text-decoration: none; margin-right: 15px; font-size: 14px; }
.sidebar { float: left; width: 220px; padding: 15px; background: #f0f0f0; min-height: 400px; }
.sidebar ul { list-style: none; padding: 0; }
.sidebar li { padding: 5px 0; }
.sidebar a { color: #333; text-decoration: none; }
.main { margin-left: 260px; padding: 20px; }
.footer { clear: both; background: #1a1a2e; color: #ccc; padding: 15px 20px; font-size: 12px; }
</style>
</head>
<body>
<div class=\"topbar\"><strong>NewsPortal</strong> &mdash; Breaking news and analysis</div>
<div class=\"nav\">
<a href=\"/\">Home</a><a href=\"/world\">World</a><a href=\"/politics\">Politics</a>
<a href=\"/tech\">Technology</a><a href=\"/sports\">Sports</a><a href=\"/opinion\">Opinion</a>
</div>
<div class=\"sidebar\">
<h3>Categories</h3>
<ul>
<li><a href=\"/cat/1\">Breaking News</a></li>
<li><a href=\"/cat/2\">Investigations</a></li>
<li><a href=\"/cat/3\">Features</a></li>
<li><a href=\"/cat/4\">Multimedia</a></li>
<li><a href=\"/cat/5\">Archive</a></li>
</ul>
<h3>Trending</h3>
<ul>
<li><a href=\"/t/1\">Story Alpha</a></li>
<li><a href=\"/t/2\">Story Beta</a></li>
<li><a href=\"/t/3\">Story Gamma</a></li>
</ul>
</div>
<div class=\"main\">
<article>
<header><h1>Featured Article</h1><span>Published: 2026-03-31</span></header>
<section>
<h2>Introduction</h2>
<p>This is the introductory paragraph with background context and important details about the story.</p>
<div class=\"inner\">
<p>#{query}</p>
</div>
</section>
<section>
<h2>Analysis</h2>
<p>Expert analysis and commentary on the developments described above.</p>
</section>
</article>
</div>
<div class=\"footer\">
<p>Copyright 2026 NewsPortal. All rights reserved. Contact: editor@example.com</p>
</div>
</body>
</html>"
  end
end
