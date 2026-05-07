def load_manifest_xss
  # NOTE: Web App Manifest fields (start_url, short_name, icons[].src,
  # shortcuts[].url) are not script-execution sinks - browsers parse them
  # as data only. We keep just the realistic case where the page fetches
  # its own manifest at runtime and feeds a field back into innerHTML.
  Xssmaze.push("manifest-level1", "/manifest/level1/?query=a", "page fetches manifest.json and innerHTMLs description field")
  maze_get "/manifest/level1/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       fetch('/manifest/level1/manifest.json?query=' + encodeURIComponent(#{query.to_json}))
         .then(function (r) { return r.json(); })
         .then(function (m) { document.getElementById('out').innerHTML = m.description; });
     </script>"
  end

  maze_get "/manifest/level1/manifest.json" do |env|
    env.response.content_type = "application/json"
    query = env.params.query["query"]
    %({"description": "#{query}"})
  end
end
