Xssmaze.push("dom-level1", "/dom/level1/", "dom write (location.href)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.href"], sinks: ["document.write"], delivery: ["fragment", "query"])
maze_get "/dom/level1/" do |_|
  "<script>
          document.write(decodeURI(location.href))
      </script>"
end

Xssmaze.push("dom-level2", "/dom/level2/", "dom write (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["document.write"], delivery: ["fragment"])
maze_get "/dom/level2/" do |_|
  "<script>
          document.write(decodeURI(location.hash))
      </script>"
end

Xssmaze.push("dom-level3", "/dom/level3/", "redirect (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["location-nav"], delivery: ["fragment"])
maze_get "/dom/level3/" do |_|
  "<script>
          document.location.href = location.hash.replace('#','')
      </script>"
end

Xssmaze.push("dom-level4", "/dom/level4/", "dom write (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["document.write"], delivery: ["query"])
maze_get "/dom/level4/" do |_|
  "<script>
          const urlParams = new URL(location.href).searchParams;
          const query = urlParams.get('query');
          document.write(query)
      </script>"
end

Xssmaze.push("dom-level5", "/dom/level5/", "dom write (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["eval"], delivery: ["query"])
maze_get "/dom/level5/" do |_|
  "<script>
          const urlParams = new URL(location.href).searchParams;
          const query = urlParams.get('query');
          eval(query)
      </script>"
end

Xssmaze.push("dom-level6", "/dom/level6/", "location.href (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["location-nav"], delivery: ["query"])
maze_get "/dom/level6/" do |_|
  "<script>
          const urlParams = new URL(location.href).searchParams;
          const query = urlParams.get('query');
          document.location.href = query
      </script>"
end

# Simple innerHTML manipulation
Xssmaze.push("dom-level7", "/dom/level7/", "innerHTML (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["innerHTML"], delivery: ["fragment"])
maze_get "/dom/level7/" do |_|
  "<div id='output'></div>
  <script>
      document.getElementById('output').innerHTML = location.hash.substring(1)
  </script>"
end

Xssmaze.push("dom-level8", "/dom/level8/", "innerHTML (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/dom/level8/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('output').innerHTML = query
  </script>"
end

# innerText manipulation (safer but can be misused)
Xssmaze.push("dom-level9", "/dom/level9/", "innerText to script tag",
  vuln: "dom", sources: ["location.search"], sinks: ["script.text"], delivery: ["query"], note: "the inline <script> is empty, so prepare-a-script returned before setting the already-started flag; mutating its text re-runs prepare and the code executes (verified in Chrome)")
maze_get "/dom/level9/" do |_|
  "<script id='scriptTag'></script>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('scriptTag').innerText = query
  </script>"
end

# Element attribute manipulation - src
Xssmaze.push("dom-level10", "/dom/level10/", "img src (query param)",
  vuln: "non-xss-control", sources: ["location.search"], sinks: ["img.src"], delivery: ["query"], exploitable: false, note: "img.src does not execute javascript: URLs in any modern browser; the taint only reaches an image URL")
maze_get "/dom/level10/" do |_|
  "<img id='image'>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('image').src = query
  </script>"
end

# Element attribute manipulation - href
Xssmaze.push("dom-level11", "/dom/level11/", "anchor href (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["anchor.href"], delivery: ["fragment"], note: "requires a user click on the anchor")
maze_get "/dom/level11/" do |_|
  "<a id='link'>Click here</a>
  <script>
      document.getElementById('link').href = location.hash.substring(1)
  </script>"
end

# document.cookie reflection
Xssmaze.push("dom-level12", "/dom/level12/", "document.write (document.cookie)", "GET", ["document.cookie"],
  vuln: "dom", sources: ["document.cookie"], sinks: ["document.write"], delivery: ["cookie"], note: "payload is delivered in the Cookie request header")
maze_get "/dom/level12/" do |_|
  "<script>
      document.write(document.cookie)
  </script>"
end

# window.name reflection
Xssmaze.push("dom-level13", "/dom/level13/", "innerHTML (window.name)", "GET", ["window.name"],
  vuln: "dom", sources: ["window.name"], sinks: ["innerHTML"], delivery: ["window-name"], note: "requires a prior navigation from a page that sets window.name")
maze_get "/dom/level13/" do |_|
  "<div id='output'></div>
  <script>
      document.getElementById('output').innerHTML = window.name
  </script>"
end

# document.referrer reflection
Xssmaze.push("dom-level14", "/dom/level14/", "document.write (document.referrer)", "GET", ["document.referrer"],
  vuln: "dom", sources: ["document.referrer"], sinks: ["document.write"], delivery: ["referer"], note: "payload is delivered in the Referer request header")
maze_get "/dom/level14/" do |_|
  "<script>
      document.write(document.referrer)
  </script>"
end

# insertAdjacentHTML
Xssmaze.push("dom-level15", "/dom/level15/", "insertAdjacentHTML (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["insertAdjacentHTML"], delivery: ["query"])
maze_get "/dom/level15/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('output').insertAdjacentHTML('beforeend', query)
  </script>"
end

# outerHTML manipulation
Xssmaze.push("dom-level16", "/dom/level16/", "outerHTML (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["outerHTML"], delivery: ["fragment"])
maze_get "/dom/level16/" do |_|
  "<div id='output'>Original content</div>
  <script>
      document.getElementById('output').outerHTML = location.hash.substring(1)
  </script>"
end

# createElement with setAttribute
Xssmaze.push("dom-level17", "/dom/level17/", "setAttribute href (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["setAttribute", "anchor.href"], delivery: ["query"], note: "requires a user click on the generated anchor")
maze_get "/dom/level17/" do |_|
  "<div id='container'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      const link = document.createElement('a');
      link.setAttribute('href', query);
      link.textContent = 'Click me';
      document.getElementById('container').appendChild(link)
  </script>"
end

# iframe src manipulation
Xssmaze.push("dom-level18", "/dom/level18/", "iframe src (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["iframe.src"], delivery: ["fragment"])
maze_get "/dom/level18/" do |_|
  "<iframe id='frame'></iframe>
  <script>
      document.getElementById('frame').src = location.hash.substring(1)
  </script>"
end

# setTimeout with string
Xssmaze.push("dom-level19", "/dom/level19/", "setTimeout (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["setTimeout"], delivery: ["query"])
maze_get "/dom/level19/" do |_|
  "<script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      setTimeout(query, 0)
  </script>"
end

# setInterval with string
Xssmaze.push("dom-level20", "/dom/level20/", "setInterval (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["setInterval"], delivery: ["fragment"])
maze_get "/dom/level20/" do |_|
  "<script>
      const hash = location.hash.substring(1);
      if(hash) setInterval(hash, 1000)
  </script>"
end

# Function constructor
Xssmaze.push("dom-level21", "/dom/level21/", "Function constructor (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["Function"], delivery: ["query"])
maze_get "/dom/level21/" do |_|
  "<script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      const fn = new Function(query);
      fn()
  </script>"
end

# JSON.parse with innerHTML
Xssmaze.push("dom-level22", "/dom/level22/", "JSON.parse + innerHTML (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"], note: "value is laundered through JSON.parse before reaching the sink")
maze_get "/dom/level22/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      try {
          const data = JSON.parse(query);
          document.getElementById('output').innerHTML = data.message
      } catch(e) {
          document.getElementById('output').innerHTML = 'Invalid JSON'
      }
  </script>"
end

# postMessage receiver
Xssmaze.push("dom-level23", "/dom/level23/", "postMessage + innerHTML", "GET", ["postMessage"],
  vuln: "dom", sources: ["postMessage"], sinks: ["innerHTML"], delivery: ["postmessage"], note: "needs an embedder/opener window to postMessage; a request-only scanner cannot deliver this")
maze_get "/dom/level23/" do |_|
  "<div id='output'></div>
  <script>
      window.addEventListener('message', function(e) {
          document.getElementById('output').innerHTML = e.data
      });
  </script>"
end

# Template literal in eval-like context
Xssmaze.push("dom-level24", "/dom/level24/", "template literal eval (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["eval"], delivery: ["query"], note: "value is interpolated into a template literal that is passed to eval")
maze_get "/dom/level24/" do |_|
  "<script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      eval('`' + query + '`')
  </script>"
end

# DOM clobbering - name attribute
Xssmaze.push("dom-level25", "/dom/level25/", "DOM clobbering (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/dom/level25/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('output').innerHTML = '<form name=\"test\">' + query + '</form>';
      if(window.test) {
          console.log('DOM clobbering detected')
      }
  </script>"
end

# document.URL reflection
Xssmaze.push("dom-level26", "/dom/level26/", "document.write (document.URL)", "GET", ["document.URL"],
  vuln: "dom", sources: ["document.URL"], sinks: ["document.write"], delivery: ["fragment", "query"])
maze_get "/dom/level26/" do |_|
  "<script>
      document.write(document.URL)
  </script>"
end

# location.search reflection
Xssmaze.push("dom-level27", "/dom/level27/", "innerHTML (location.search)",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"], note: "reads the raw query string, not a named parameter")
maze_get "/dom/level27/" do |_|
  "<div id='output'></div>
  <script>
      document.getElementById('output').innerHTML = location.search.substring(1)
  </script>"
end

# location.pathname reflection
Xssmaze.push("dom-level28", "/dom/level28/", "document.write (location.pathname)",
  vuln: "dom", sources: ["location.pathname"], sinks: ["document.write"], delivery: ["path"])
maze_get "/dom/level28/" do |_|
  "<script>
      document.write(location.pathname)
  </script>"
end

# Anchor element with javascript: protocol
Xssmaze.push("dom-level29", "/dom/level29/", "anchor click with javascript: (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["anchor.href"], delivery: ["query"], note: "requires a user click on the anchor")
maze_get "/dom/level29/" do |_|
  "<a id='link' href='#'>Click me</a>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('link').href = 'javascript:' + query
  </script>"
end

# document.execCommand (legacy but still works in some contexts)
Xssmaze.push("dom-level30", "/dom/level30/", "insertHTML execCommand (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["execCommand.insertHTML"], delivery: ["query"], note: "execCommand('insertHTML') is deprecated; Chromium only")
maze_get "/dom/level30/" do |_|
  "<div id='editor' contenteditable='true'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('editor').focus();
      document.execCommand('insertHTML', false, query)
  </script>"
end

# Range.createContextualFragment
Xssmaze.push("dom-level31", "/dom/level31/", "createContextualFragment (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["createContextualFragment"], delivery: ["fragment"])
maze_get "/dom/level31/" do |_|
  "<div id='output'></div>
  <script>
      const range = document.createRange();
      const fragment = range.createContextualFragment(location.hash.substring(1));
      document.getElementById('output').appendChild(fragment)
  </script>"
end

# DOMParser
Xssmaze.push("dom-level32", "/dom/level32/", "DOMParser (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["DOMParser", "innerHTML"], delivery: ["query"])
maze_get "/dom/level32/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      const parser = new DOMParser();
      const doc = parser.parseFromString(query, 'text/html');
      document.getElementById('output').innerHTML = doc.body.innerHTML
  </script>"
end

# Multiple URL parameters concatenated
Xssmaze.push("dom-level33", "/dom/level33/", "multiple params concatenation", "GET", ["query", "query2"],
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"], note: "payload must be split across the query and query2 parameters")
maze_get "/dom/level33/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const param1 = urlParams.get('query') || '';
      const param2 = urlParams.get('query2') || '';
      document.getElementById('output').innerHTML = param1 + param2
  </script>"
end

# Object property access
Xssmaze.push("dom-level34", "/dom/level34/", "object property innerHTML (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/dom/level34/" do |_|
  "<div id='output'></div>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      const obj = { value: query };
      document.getElementById('output').innerHTML = obj.value
  </script>"
end

# Array join
Xssmaze.push("dom-level35", "/dom/level35/", "array join innerHTML (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["innerHTML"], delivery: ["fragment"], note: "value is laundered through split(',') / join('')")
maze_get "/dom/level35/" do |_|
  "<div id='output'></div>
  <script>
      const parts = location.hash.substring(1).split(',');
      document.getElementById('output').innerHTML = parts.join('')
  </script>"
end

# iframe srcdoc property assignment (location.hash) — a full HTML document is
# parsed inside the frame, so an inline <script> here actually executes.
Xssmaze.push("dom-level36", "/dom/level36/", "iframe srcdoc property (location.hash)", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["srcdoc"], delivery: ["fragment"])
maze_get "/dom/level36/" do |_|
  "<iframe id='frame'></iframe>
  <script>
      document.getElementById('frame').srcdoc = decodeURIComponent(location.hash.substring(1))
  </script>"
end

# iframe srcdoc property assignment (query param)
Xssmaze.push("dom-level37", "/dom/level37/", "iframe srcdoc property (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["srcdoc"], delivery: ["query"])
maze_get "/dom/level37/" do |_|
  "<iframe id='frame'></iframe>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('frame').srcdoc = query
  </script>"
end

# iframe srcdoc via setAttribute (query param) — the attribute-name path some
# scanners model separately from the .srcdoc property assignment.
Xssmaze.push("dom-level38", "/dom/level38/", "iframe srcdoc via setAttribute (query param)",
  vuln: "dom", sources: ["location.search"], sinks: ["setAttribute", "srcdoc"], delivery: ["query"])
maze_get "/dom/level38/" do |_|
  "<iframe id='frame'></iframe>
  <script>
      const urlParams = new URL(location.href).searchParams;
      const query = urlParams.get('query');
      document.getElementById('frame').setAttribute('srcdoc', query)
  </script>"
end
