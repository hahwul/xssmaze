def load_worker_xss
  # Workers themselves can't touch the DOM, so "worker XSS" really means
  # the worker is a relay: attacker payload travels through the worker
  # boundary and the *page* unsafely consumes the worker's output.

  Xssmaze.push("worker-level1", "/worker/level1/?query=a", "page innerHTMLs whatever the worker postMessages back")
  maze_get "/worker/level1/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var b = new Blob(['onmessage = function (e) { self.postMessage(e.data) }'], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
       w.postMessage(#{query.to_json});
     </script>"
  end

  Xssmaze.push("worker-level2", "/worker/level2/?query=a", "Worker source built by string concat (untrusted code in worker)")
  maze_get "/worker/level2/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       // The query is concatenated into the worker source; any code there runs in
       // the worker scope and can postMessage arbitrary text/HTML back to the page.
       var src = 'self.postMessage(' + #{query.to_json} + ')';
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
     </script>"
  end

  Xssmaze.push("worker-level3", "/worker/level3/?query=a", "importScripts() with attacker-controlled URL")
  maze_get "/worker/level3/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       // Worker pulls remote script via importScripts(query); any side-effect the
       // imported script publishes via postMessage lands in the page innerHTML.
       var src = 'try { importScripts(' + #{query.to_json} + ') } catch(e) {} self.postMessage(\"loaded\")';
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
     </script>"
  end

  Xssmaze.push("worker-level4", "/worker/level4/?query=a", "worker eval gadget: page posts query, worker eval()s, returns to innerHTML")
  maze_get "/worker/level4/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var src = 'onmessage = function (e) { try { self.postMessage(eval(e.data)) } catch (err) { self.postMessage(String(err)) } }';
       var b = new Blob([src], { type: 'application/javascript' });
       var w = new Worker(URL.createObjectURL(b));
       w.onmessage = function (e) { document.getElementById('out').innerHTML = e.data; };
       w.postMessage(#{query.to_json});
     </script>"
  end
end
