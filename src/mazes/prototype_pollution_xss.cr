def load_prototype_pollution_xss
  Xssmaze.push("prototype-pollution-level1", "/prototype-pollution/level1/?query=a", "prototype pollution via __proto__ + innerHTML gadget")
  maze_get "/prototype-pollution/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Prototype Pollution Level 1</h1>
    <div id='output'></div>
    <script>
      function merge(target, source) {
        for (var key in source) {
          if (typeof source[key] === 'object' && source[key] !== null) {
            if (!target[key]) target[key] = {};
            merge(target[key], source[key]);
          } else {
            target[key] = source[key];
          }
        }
        return target;
      }

      try {
        var userObj = JSON.parse('#{query}');
        var config = {};
        merge(config, userObj);
      } catch(e) {}

      var el = document.createElement('div');
      if (el.innerHTML !== undefined && ({}).html) {
        document.getElementById('output').innerHTML = ({}).html;
      } else {
        document.getElementById('output').textContent = 'No pollution detected';
      }
    </script>
    </body></html>"
  end

  Xssmaze.push("prototype-pollution-level2", "/prototype-pollution/level2/?query=a", "prototype pollution via constructor.prototype + src gadget")
  maze_get "/prototype-pollution/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Prototype Pollution Level 2</h1>
    <div id='output'></div>
    <script>
      function deepAssign(target, source) {
        for (var key in source) {
          if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
            if (!target[key]) target[key] = {};
            deepAssign(target[key], source[key]);
          } else {
            target[key] = source[key];
          }
        }
      }

      try {
        var input = JSON.parse('#{query}');
        var obj = {};
        deepAssign(obj, input);
      } catch(e) {}

      var scriptEl = document.createElement('script');
      if (({}).src) {
        scriptEl.src = ({}).src;
        document.body.appendChild(scriptEl);
      }
      document.getElementById('output').textContent = 'Check console';
    </script>
    </body></html>"
  end

  Xssmaze.push("prototype-pollution-level3", "/prototype-pollution/level3/?query=a", "prototype pollution via Object.assign + srcdoc gadget")
  maze_get "/prototype-pollution/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Prototype Pollution Level 3</h1>
    <iframe id='frame'></iframe>
    <script>
      function unsafeMerge(target, source) {
        Object.keys(source).forEach(function(key) {
          if (key === '__proto__' || key === 'constructor') {
            // Intentionally vulnerable: shallow check only
            if (typeof source[key] === 'object') {
              Object.keys(source[key]).forEach(function(k) {
                target[key][k] = source[key][k];
              });
            }
          } else {
            target[key] = source[key];
          }
        });
      }

      try {
        var payload = JSON.parse('#{query}');
        var config = {};
        unsafeMerge(config, payload);
      } catch(e) {}

      var opts = {};
      if (({}).srcdoc) {
        document.getElementById('frame').srcdoc = ({}).srcdoc;
      }
    </script>
    </body></html>"
  end

  Xssmaze.push("prototype-pollution-level4", "/prototype-pollution/level4/?query=a", "prototype pollution via URL hash JSON + eval gadget")
  maze_get "/prototype-pollution/level4/" do |_|
    "<html><body>
    <h1>Prototype Pollution Level 4</h1>
    <div id='output'></div>
    <script>
      function vulnerableMerge(base, override) {
        for (var key in override) {
          if (typeof override[key] === 'object' && override[key] !== null) {
            if (!base[key]) base[key] = {};
            vulnerableMerge(base[key], override[key]);
          } else {
            base[key] = override[key];
          }
        }
      }

      var params = new URL(location.href).searchParams;
      var q = params.get('query') || '{}';
      try {
        var data = JSON.parse(q);
        vulnerableMerge({}, data);
      } catch(e) {}

      var config = { onInit: null };
      var action = config.onInit || ({}).onInit;
      if (action) {
        new Function(action)();
      }
      document.getElementById('output').textContent = 'Check for pollution';
    </script>
    </body></html>"
  end
end
