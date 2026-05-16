# Each level reflects into JS but only fires when the user pastes/copies
# something into the page - the channel itself is the sink. No "bootstrap"
# innerHTML reflection from the query, so these are real clipboard XSS
# cases (require user interaction) rather than disguised reflection XSS.

Xssmaze.push("clipboard-level1", "/clipboard/level1/?query=a", "paste handler innerHTMLs clipboardData.getData('text/html')")
maze_get "/clipboard/level1/" do |env|
  # Query is reflected into a JS string that the paste handler concatenates
  # with the pasted HTML and writes via innerHTML.
  query = env.params.query["query"]
  "<div id='paste' contenteditable>paste here</div>
   <div id='out'></div>
   <script>
     var prefix = #{query.to_json};
     document.getElementById('paste').addEventListener('paste', function (e) {
       var html = e.clipboardData.getData('text/html');
       document.getElementById('out').innerHTML = prefix + html;
     });
   </script>"
end

Xssmaze.push("clipboard-level2", "/clipboard/level2/?query=a", "navigator.clipboard.readText concatenated with reflected prefix")
maze_get "/clipboard/level2/" do |env|
  query = env.params.query["query"]
  "<button id='b'>read</button><div id='out'></div>
   <script>
     var prefix = #{query.to_json};
     document.getElementById('b').addEventListener('click', function () {
       navigator.clipboard.readText().then(function (t) {
         document.getElementById('out').innerHTML = prefix + t;
       });
     });
   </script>"
end

Xssmaze.push("clipboard-level3", "/clipboard/level3/?query=a", "copy event sets reflected text/html on dataTransfer (sink: target page)")
maze_get "/clipboard/level3/" do |env|
  query = env.params.query["query"]
  "<div id='src'>copy me</div>
   <p>This page poisons the clipboard with attacker-controlled HTML; the XSS fires when the user pastes into a renderer (rich text editor, mail client).</p>
   <script>
     document.getElementById('src').addEventListener('copy', function (e) {
       e.clipboardData.setData('text/html', #{query.to_json});
       e.preventDefault();
     });
   </script>"
end

Xssmaze.push("clipboard-level4", "/clipboard/level4/?query=a", "ClipboardItem blob text/html consumed by paste-listener page")
maze_get "/clipboard/level4/" do |env|
  query = env.params.query["query"]
  "<button id='b'>copy</button>
   <p>Click to push a text/html ClipboardItem; XSS fires in any page whose paste handler innerHTMLs the html mime type.</p>
   <script>
     document.getElementById('b').addEventListener('click', async function () {
       var blob = new Blob([#{query.to_json}], { type: 'text/html' });
       await navigator.clipboard.write([new ClipboardItem({ 'text/html': blob })]);
     });
   </script>"
end
