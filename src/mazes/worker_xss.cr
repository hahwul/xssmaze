def load_worker_xss
  Xssmaze.push("worker-level1", "/worker/level1/?query=a", "Web Worker built from blob with reflected source")
  maze_get "/worker/level1/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var src = 'self.postMessage(' + #{query.to_json} + ')';
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
     </script>"
  end

  Xssmaze.push("worker-level2", "/worker/level2/?query=a", "importScripts() with reflected URL")
  maze_get "/worker/level2/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var src = \"importScripts(\" + #{query.to_json} + \"); self.postMessage('done');\";
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').textContent = e.data; };
     </script>"
  end

  Xssmaze.push("worker-level3", "/worker/level3/?query=a", "worker postMessage echoed into innerHTML")
  maze_get "/worker/level3/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var b = new Blob(['self.onmessage = function (e) { self.postMessage(e.data) }'], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
       w.postMessage(#{query.to_json});
     </script>"
  end

  Xssmaze.push("worker-level4", "/worker/level4/?query=a", "shared module worker eval gadget")
  maze_get "/worker/level4/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var src = 'onmessage = function (e) { self.postMessage(eval(e.data)) }';
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
       w.postMessage(#{query.to_json});
     </script>"
  end
end
