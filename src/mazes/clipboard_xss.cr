def load_clipboard_xss
  Xssmaze.push("clipboard-level1", "/clipboard/level1/?query=a", "paste event reads clipboardData and innerHTMLs it")
  maze_get "/clipboard/level1/" do |env|
    query = env.params.query["query"]
    "<div id='paste' contenteditable>paste here</div>
     <div id='out'></div>
     <script>
       // bootstrap from query so headless tools can trigger without paste UI
       document.getElementById('out').innerHTML = #{query.to_json};
       document.getElementById('paste').addEventListener('paste', function (e) {
         var html = e.clipboardData.getData('text/html');
         document.getElementById('out').innerHTML = html;
       });
     </script>"
  end

  Xssmaze.push("clipboard-level2", "/clipboard/level2/?query=a", "navigator.clipboard.readText sink with reflected initializer")
  maze_get "/clipboard/level2/" do |env|
    query = env.params.query["query"]
    "<button id='b'>read</button><div id='out'></div>
     <script>
       var seed = #{query.to_json};
       document.getElementById('out').innerHTML = seed;
       document.getElementById('b').addEventListener('click', function () {
         navigator.clipboard.readText().then(function (t) {
           document.getElementById('out').innerHTML = seed + t;
         });
       });
     </script>"
  end

  Xssmaze.push("clipboard-level3", "/clipboard/level3/?query=a", "copy event handler sets injected payload as text/html")
  maze_get "/clipboard/level3/" do |env|
    query = env.params.query["query"]
    "<div id='src'>copy me</div>
     <script>
       document.getElementById('src').addEventListener('copy', function (e) {
         e.clipboardData.setData('text/html', #{query.to_json});
         e.preventDefault();
       });
       // sink for headless triggering
       var d = document.createElement('div');
       d.innerHTML = #{query.to_json};
       document.body.appendChild(d);
     </script>"
  end

  Xssmaze.push("clipboard-level4", "/clipboard/level4/?query=a", "ClipboardItem blob with reflected text/html")
  maze_get "/clipboard/level4/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var blob = new Blob([#{query.to_json}], { type: 'text/html' });
       blob.text().then(function (t) {
         document.getElementById('out').innerHTML = t;
       });
     </script>"
  end
end
