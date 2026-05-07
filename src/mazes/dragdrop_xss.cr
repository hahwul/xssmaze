def load_dragdrop_xss
  # Genuine drag-and-drop XSS: the channel is the sink, no shortcut path.

  Xssmaze.push("dragdrop-level1", "/dragdrop/level1/?query=a", "drop handler innerHTMLs dataTransfer.getData('text/html') (reflected prefix)")
  maze_get "/dragdrop/level1/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='border:1px dashed #999;padding:30px'>drop here</div>
     <div id='out'></div>
     <script>
       var prefix = #{query.to_json};
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         document.getElementById('out').innerHTML = prefix + e.dataTransfer.getData('text/html');
       });
     </script>"
  end

  Xssmaze.push("dragdrop-level2", "/dragdrop/level2/?query=a", "dragstart sets reflected text/html (XSS fires in target page)")
  maze_get "/dragdrop/level2/" do |env|
    query = env.params.query["query"]
    "<div id='src' draggable='true' style='cursor:move;padding:8px;border:1px solid #ccc'>drag me</div>
     <p>Dragging this element copies attacker-controlled HTML onto the dataTransfer; XSS fires in any drop target that innerHTMLs text/html.</p>
     <script>
       document.getElementById('src').addEventListener('dragstart', function (e) {
         e.dataTransfer.setData('text/html', #{query.to_json});
       });
     </script>"
  end

  Xssmaze.push("dragdrop-level3", "/dragdrop/level3/?query=a", "drop builds <a href> from dropped text/uri-list (no escaping)")
  maze_get "/dragdrop/level3/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='padding:30px;border:1px solid #ccc'>drop link</div>
     <div id='out'></div>
     <script>
       var prefix = #{query.to_json};
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         var u = e.dataTransfer.getData('text/uri-list') || e.dataTransfer.getData('text/plain');
         document.getElementById('out').innerHTML = '<a href=' + u + '>' + prefix + '</a>';
       });
     </script>"
  end

  Xssmaze.push("dragdrop-level4", "/dragdrop/level4/?query=a", "drop reads files[0] as text/html via FileReader.innerHTML")
  maze_get "/dragdrop/level4/" do |env|
    query = env.params.query["query"]
    "<div id='zone' style='padding:30px;border:1px solid #ccc'>drop file</div>
     <div id='out'></div>
     <script>
       var prefix = #{query.to_json};
       var z = document.getElementById('zone');
       z.addEventListener('dragover', function (e) { e.preventDefault(); });
       z.addEventListener('drop', function (e) {
         e.preventDefault();
         var f = e.dataTransfer.files[0];
         if (!f) return;
         var r = new FileReader();
         r.onload = function () { document.getElementById('out').innerHTML = prefix + r.result; };
         r.readAsText(f);
       });
     </script>"
  end
end
