def load_complex_page_xss
  # Level 1: Full page with header/nav/main/footer, query reflected in main content div
  Xssmaze.push("complexpage-level1", "/complexpage/level1/?query=a", "full page with header/nav/footer, reflection in content div")
  maze_get "/complexpage/level1/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Complex Page Level 1</title></head>
<body>
<header><h1>Site Header</h1><p>Welcome to our site</p></header>
<nav><ul><li><a href=\"/\">Home</a></li><li><a href=\"/about\">About</a></li><li><a href=\"/contact\">Contact</a></li></ul></nav>
<main>
<div class=\"content\">#{query}</div>
</main>
<footer><p>Copyright 2026 Example Corp</p></footer>
</body>
</html>"
  end

  # Level 2: Full page with sidebar, query reflected in search input value
  Xssmaze.push("complexpage-level2", "/complexpage/level2/?query=a", "full page with sidebar, reflection in search input value")
  maze_get "/complexpage/level2/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Complex Page Level 2</title></head>
<body>
<header><h1>Dashboard</h1></header>
<div id=\"wrapper\">
<aside class=\"sidebar\">
<h3>Search</h3>
<input type=\"search\" value=\"#{query}\">
<ul><li><a href=\"/page1\">Page 1</a></li><li><a href=\"/page2\">Page 2</a></li></ul>
</aside>
<main><p>Main content area</p></main>
</div>
<footer><p>Footer content</p></footer>
</body>
</html>"
  end

  # Level 3: Full page with multiple scripts, query reflected in h2 title
  Xssmaze.push("complexpage-level3", "/complexpage/level3/?query=a", "full page with multiple scripts, reflection in h2 title")
  maze_get "/complexpage/level3/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\"><title>Complex Page Level 3</title>
<script>var config = {debug: false, version: '1.0'};</script>
</head>
<body>
<script>console.log('page loaded');</script>
<div id=\"app\">
<h2 class=\"title\">#{query}</h2>
<p>Some paragraph text below the title.</p>
</div>
<script>document.addEventListener('DOMContentLoaded', function(){ console.log('ready'); });</script>
</body>
</html>"
  end

  # Level 4: Full page with CSS, query reflected in paragraph description
  Xssmaze.push("complexpage-level4", "/complexpage/level4/?query=a", "full page with CSS styles, reflection in description paragraph")
  maze_get "/complexpage/level4/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\"><title>Complex Page Level 4</title>
<style>
body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
.container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
.description { color: #555; line-height: 1.6; font-size: 16px; }
h1 { color: #333; border-bottom: 2px solid #0066cc; padding-bottom: 10px; }
</style>
</head>
<body>
<div class=\"container\">
<h1>Styled Page</h1>
<p class=\"description\">#{query}</p>
<div class=\"footer\">Page rendered successfully.</div>
</div>
</body>
</html>"
  end

  # Level 5: Full page with forms and tables, query reflected in table data cell
  Xssmaze.push("complexpage-level5", "/complexpage/level5/?query=a", "full page with forms and tables, reflection in td element")
  maze_get "/complexpage/level5/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head><meta charset=\"UTF-8\"><title>Complex Page Level 5</title></head>
<body>
<h1>Data Dashboard</h1>
<form action=\"/search\" method=\"get\">
<label for=\"s\">Search:</label><input id=\"s\" type=\"text\" name=\"s\"><button type=\"submit\">Go</button>
</form>
<table border=\"1\" cellpadding=\"5\">
<thead><tr><th>ID</th><th>Name</th><th>Data</th></tr></thead>
<tbody>
<tr><td>1</td><td>Item A</td><td>100</td></tr>
<tr><td>2</td><td>Item B</td><td class=\"data\">#{query}</td></tr>
<tr><td>3</td><td>Item C</td><td>300</td></tr>
</tbody>
</table>
<p>Total records: 3</p>
</body>
</html>"
  end

  # Level 6: Full page with lots of HTML (>1000 chars before reflection), query deep in page
  Xssmaze.push("complexpage-level6", "/complexpage/level6/?query=a", "large page with reflection deep in HTML (>1000 chars before reflection)")
  maze_get "/complexpage/level6/" do |env|
    query = env.params.query["query"]

    "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\"><title>Complex Page Level 6</title>
<style>
body { font-family: Georgia, serif; margin: 0; padding: 0; }
.header { background: #2c3e50; color: white; padding: 20px 40px; }
.nav { background: #34495e; padding: 10px 40px; }
.nav a { color: #ecf0f1; text-decoration: none; margin-right: 20px; }
.main { padding: 40px; max-width: 1200px; margin: 0 auto; }
.sidebar { float: right; width: 300px; background: #f9f9f9; padding: 20px; }
.content { margin-right: 340px; }
.footer { clear: both; background: #2c3e50; color: white; padding: 20px 40px; margin-top: 40px; }
</style>
</head>
<body>
<div class=\"header\">
<h1>Enterprise Portal</h1>
<p>Your one-stop solution for enterprise resource management and analytics dashboard viewing platform.</p>
</div>
<div class=\"nav\">
<a href=\"/\">Home</a><a href=\"/products\">Products</a><a href=\"/services\">Services</a>
<a href=\"/about\">About Us</a><a href=\"/contact\">Contact</a><a href=\"/blog\">Blog</a>
<a href=\"/support\">Support</a><a href=\"/faq\">FAQ</a>
</div>
<div class=\"main\">
<div class=\"sidebar\">
<h3>Quick Links</h3>
<ul>
<li><a href=\"/dashboard\">Dashboard</a></li>
<li><a href=\"/reports\">Reports</a></li>
<li><a href=\"/analytics\">Analytics</a></li>
<li><a href=\"/settings\">Settings</a></li>
<li><a href=\"/profile\">Profile</a></li>
</ul>
<h3>Recent Activity</h3>
<p>No recent activity to display. Please check back later for updates on your account status and notifications.</p>
</div>
<div class=\"content\">
<h2>Search Results</h2>
<p>Showing results for your query. The system has processed your request through multiple filters and analyzers.</p>
<p>Below are the matched results from our comprehensive database of records, documents, and indexed pages.</p>
<div id=\"result\">#{query}</div>
<p>End of results. If you did not find what you were looking for, please refine your search criteria.</p>
</div>
</div>
<div class=\"footer\">
<p>Copyright 2026 Enterprise Corp. All rights reserved. Terms of Service. Privacy Policy.</p>
</div>
</body>
</html>"
  end
end
