# In-memory store for stored XSS scenarios. Registered up front rather than
# on first POST so an idle lab still reports all four levels on `GET /reset`.
stored_data = {
  "level1" => Xssmaze::Store.list("stored/level1"),
  "level2" => Xssmaze::Store.list("stored/level2"),
  "level3" => Xssmaze::Store.list("stored/level3"),
  "level4" => Xssmaze::Store.list("stored/level4"),
}

Xssmaze.push("stored-level1", "/stored/level1/", "stored XSS via guestbook (no filter)", "POST")
maze_get "/stored/level1/" do |_|
  entries = stored_data["level1"].entries.map { |e| "<li>#{e}</li>" }.join
  "<html><body>
  <h1>Stored XSS Level 1</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <ul>#{entries}</ul>
  </body></html>"
end
maze_post "/stored/level1/" do |env|
  query = env.params.body["query"].as(String)
  stored_data["level1"] << query
  entries = stored_data["level1"].entries.map { |e| "<li>#{e}</li>" }.join
  "<html><body>
  <h1>Stored XSS Level 1</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <ul>#{entries}</ul>
  </body></html>"
end

Xssmaze.push("stored-level2", "/stored/level2/", "stored XSS with angle bracket filter", "POST")
maze_get "/stored/level2/" do |_|
  entries = stored_data["level2"].entries.map { |e| "<li>#{e}</li>" }.join
  "<html><body>
  <h1>Stored XSS Level 2</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <ul>#{entries}</ul>
  </body></html>"
end
maze_post "/stored/level2/" do |env|
  query = Filters.strip_angles(env.params.body["query"].as(String))
  stored_data["level2"] << query
  entries = stored_data["level2"].entries.map { |e| "<li>#{e}</li>" }.join
  "<html><body>
  <h1>Stored XSS Level 2</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <ul>#{entries}</ul>
  </body></html>"
end

Xssmaze.push("stored-level3", "/stored/level3/", "stored XSS in attribute context", "POST")
maze_get "/stored/level3/" do |_|
  entries = stored_data["level3"].entries.map { |e| "<div title=\"#{e}\">#{Filters.encode_angles(e)}</div>" }.join
  "<html><body>
  <h1>Stored XSS Level 3</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  #{entries}
  </body></html>"
end
maze_post "/stored/level3/" do |env|
  query = env.params.body["query"].as(String)
  stored_data["level3"] << query
  entries = stored_data["level3"].entries.map { |e| "<div title=\"#{e}\">#{Filters.encode_angles(e)}</div>" }.join
  "<html><body>
  <h1>Stored XSS Level 3</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  #{entries}
  </body></html>"
end

Xssmaze.push("stored-level4", "/stored/level4/", "stored XSS in JSON API response rendered via innerHTML", "POST")
maze_get "/stored/level4/" do |_|
  "<html><body>
  <h1>Stored XSS Level 4</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <div id='output'></div>
  <script>
    fetch('/stored/level4/api').then(r=>r.json()).then(data=>{
      document.getElementById('output').innerHTML = data.entries.map(e=>'<p>'+e+'</p>').join('');
    });
  </script>
  </body></html>"
end
maze_post "/stored/level4/" do |env|
  query = env.params.body["query"].as(String)
  stored_data["level4"] << query
  "<html><body>
  <h1>Stored XSS Level 4</h1>
  <form method='post'><input name='query' value='a'><input type='submit' value='Post'></form>
  <div id='output'></div>
  <script>
    fetch('/stored/level4/api').then(r=>r.json()).then(data=>{
      document.getElementById('output').innerHTML = data.entries.map(e=>'<p>'+e+'</p>').join('');
    });
  </script>
  </body></html>"
end
get "/stored/level4/api" do |env|
  env.response.content_type = "application/json"
  {entries: stored_data["level4"].entries}.to_json
end
