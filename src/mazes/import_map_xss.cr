def load_import_map_xss
  Xssmaze.push("import-map-level1", "/import-map/level1/?query=a", "import map injection via script type=importmap")
  maze_get "/import-map/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Import Map Level 1</h1>
    <script type='importmap'>
    {
      \"imports\": {
        \"util\": \"#{query}\"
      }
    }
    </script>
    <script type='module'>
      import 'util';
    </script>
    </body></html>"
  end

  Xssmaze.push("import-map-level2", "/import-map/level2/?query=a", "import map injection with data: URI module")
  maze_get "/import-map/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Import Map Level 2</h1>
    <div id='output'></div>
    <script>
      var mapScript = document.createElement('script');
      mapScript.type = 'importmap';
      mapScript.textContent = JSON.stringify({
        imports: { 'app': '#{query}' }
      });
      document.head.appendChild(mapScript);
    </script>
    </body></html>"
  end

  Xssmaze.push("import-map-level3", "/import-map/level3/?query=a", "dynamic import() with user-controlled specifier")
  maze_get "/import-map/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Import Map Level 3</h1>
    <div id='output'></div>
    <script type='module'>
      var url = '#{query}';
      try {
        await import(url);
      } catch(e) {
        document.getElementById('output').textContent = 'Import failed: ' + e.message;
      }
    </script>
    </body></html>"
  end
end
