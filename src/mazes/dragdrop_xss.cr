def load_dragdrop_xss
  Xssmaze.push("dragdrop-level1", "/dragdrop/level1/?query=a", "drop handler injects dataTransfer.getData('text/html')")
  maze_get "/dragdrop/level1/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='border:1px dashed #999;padding:30px'>drop here</div>
     <div id='out'></div>
     <script>
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         document.getElementById('out').innerHTML = e.dataTransfer.getData('text/html');
       });
       // bootstrap path for headless tools
       document.getElementById('out').innerHTML = #{query.to_json};
     </script>"
  end

  Xssmaze.push("dragdrop-level2", "/dragdrop/level2/?query=a", "dragstart sets reflected text/html on dataTransfer")
  maze_get "/dragdrop/level2/" do |env|
    query = env.params.query["query"]
    "<div id='src' draggable='true' style='cursor:move'>drag me</div>
     <div id='out'></div>
     <script>
       document.getElementById('src').addEventListener('dragstart', function (e) {
         e.dataTransfer.setData('text/html', #{query.to_json});
       });
       document.getElementById('out').innerHTML = #{query.to_json};
     </script>"
  end

  Xssmaze.push("dragdrop-level3", "/dragdrop/level3/?query=a", "drop sink builds <a href> from dropped URL")
  maze_get "/dragdrop/level3/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='padding:30px;border:1px solid #ccc'>drop link</div>
     <div id='out'></div>
     <script>
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         var u = e.dataTransfer.getData('text/uri-list') || e.dataTransfer.getData('text/plain');
         document.getElementById('out').innerHTML = '<a href=' + u + '>open</a>';
       });
       document.getElementById('out').innerHTML = '<a href=' + #{query.to_json} + '>open</a>';
     </script>"
  end

  Xssmaze.push("dragdrop-level4", "/dragdrop/level4/?query=a", "drop reads files[0] as text/html via FileReader")
  maze_get "/dragdrop/level4/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='padding:30px;border:1px solid #ccc'>drop file</div>
     <div id='out'></div>
     <script>
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         var f = e.dataTransfer.files[0];
         if (!f) return;
         var r = new FileReader();
         r.onload = function () { document.getElementById('out').innerHTML = r.result; };
         r.readAsText(f);
       });
       document.getElementById('out').innerHTML = #{query.to_json};
     </script>"
  end
end
