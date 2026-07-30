# Taint-propagation shapes, not new sources or sinks.
#
# Every level here is the same trivial flow — read a URL parameter, write it
# to innerHTML — with one laundering step in between. The source and the sink
# are both obvious; the question is whether an analyzer can still connect them
# once the value has been round-tripped through a serializer, hidden behind a
# Proxy trap or an accessor, or carried across an await / Promise boundary.
#
# A tool that reports every level in this category has real dataflow. A tool
# that reports none of them is pattern-matching `innerHTML =` against a
# literal `location.search` in the same expression.

# Level 1: JSON.stringify / JSON.parse round-trip. The value leaves the JS
# heap as text and comes back as a different object.
Xssmaze.push("taintflow-level1", "/taintflow/level1/?query=a", "value laundered through a JSON.stringify/JSON.parse round-trip",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "taint crosses a serialize/deserialize boundary before the sink")
maze_get "/taintflow/level1/" do |_env|
  "<html><body>
  <h1>Round-Tripped Draft</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var restored = JSON.parse(JSON.stringify({ body: q }));
    document.getElementById('out').innerHTML = restored.body;
  </script>
  </body></html>"
end

# Level 2: Proxy get trap. The property read that produces the tainted value
# is a function call on a handler object, not a property access on the store.
Xssmaze.push("taintflow-level2", "/taintflow/level2/", "value laundered through a Proxy get trap", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["innerHTML"], delivery: ["fragment"],
  note: "the sink reads a property whose value is produced by a Proxy get trap")
maze_get "/taintflow/level2/" do |_env|
  "<html><body>
  <h1>Proxied Store</h1>
  <div id='out'></div>
  <script>
    var raw = decodeURIComponent(location.hash.slice(1));
    var store = new Proxy({ body: raw }, {
      get: function (target, prop) { return target[prop]; }
    });
    if (store.body) { document.getElementById('out').innerHTML = store.body; }
  </script>
  </body></html>"
end

# Level 3: class accessor. The taint is stashed on a private-ish field and
# handed back out by a getter.
Xssmaze.push("taintflow-level3", "/taintflow/level3/?query=a", "value laundered through a class getter",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "the sink reads an accessor property, not the field the value was written to")
maze_get "/taintflow/level3/" do |_env|
  "<html><body>
  <h1>Model Accessor</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    class Message {
      constructor(value) { this._value = value; }
      get body() { return this._value; }
    }
    document.getElementById('out').innerHTML = new Message(q).body;
  </script>
  </body></html>"
end

# Level 4: async/await. The value crosses a microtask boundary through an
# awaited async function rather than a .then() chain.
Xssmaze.push("taintflow-level4", "/taintflow/level4/?query=a", "value laundered through an async/await boundary",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "taint crosses an await, not a .then() callback")
maze_get "/taintflow/level4/" do |_env|
  "<html><body>
  <h1>Awaited Load</h1>
  <div id='out'>loading...</div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    async function load(value) {
      return await Promise.resolve(value);
    }
    (async function () {
      var body = await load(q);
      document.getElementById('out').innerHTML = body;
    })();
  </script>
  </body></html>"
end

# Level 5: Promise.all. The value is one element of a settled-array
# destructure, so it arrives by index rather than by name.
Xssmaze.push("taintflow-level5", "/taintflow/level5/?query=a", "value laundered through a Promise.all result array",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "the tainted element is identified only by its index in the Promise.all result")
maze_get "/taintflow/level5/" do |_env|
  "<html><body>
  <h1>Parallel Fetches</h1>
  <div id='out'>loading...</div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    Promise.all([
      Promise.resolve('<section>'),
      Promise.resolve(q),
      Promise.resolve('</section>')
    ]).then(function (parts) {
      document.getElementById('out').innerHTML = parts.join('');
    });
  </script>
  </body></html>"
end

# Level 6: structuredClone. A structured deep copy across the same boundary
# postMessage uses, but entirely in-process.
Xssmaze.push("taintflow-level6", "/taintflow/level6/?query=a", "value laundered through structuredClone",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "structuredClone deep-copies the wrapper object; the sink reads the copy")
maze_get "/taintflow/level6/" do |_env|
  "<html><body>
  <h1>Cloned State</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var snapshot = structuredClone({ payload: { body: q } });
    document.getElementById('out').innerHTML = snapshot.payload.body;
  </script>
  </body></html>"
end

# Level 7: tagged template. The value never appears in the template literal's
# cooked string — it arrives as a positional argument to the tag function.
Xssmaze.push("taintflow-level7", "/taintflow/level7/", "value laundered through a tagged template function", "GET", ["#hash"],
  vuln: "dom", sources: ["location.hash"], sinks: ["innerHTML"], delivery: ["fragment"],
  note: "the interpolation is delivered as an argument to a tag function, not spliced into the literal")
maze_get "/taintflow/level7/" do |_env|
  "<html><body>
  <h1>Tagged Template</h1>
  <div id='out'></div>
  <script>
    var raw = decodeURIComponent(location.hash.slice(1));
    function html(strings, value) {
      return strings[0] + value + strings[1];
    }
    if (raw) {
      document.getElementById('out').innerHTML = html`<article>${raw}</article>`;
    }
  </script>
  </body></html>"
end

# Level 8: String.prototype.replace with a function replacer. The tainted
# value is the *return value* of a callback, never an argument to replace().
Xssmaze.push("taintflow-level8", "/taintflow/level8/?query=a", "value laundered through a String.replace replacer function",
  vuln: "dom", sources: ["location.search"], sinks: ["innerHTML"], delivery: ["query"],
  note: "the value is returned by the replacer callback; replace() itself never receives it")
maze_get "/taintflow/level8/" do |_env|
  "<html><body>
  <h1>Template Filler</h1>
  <div id='out'></div>
  <script>
    var q = new URLSearchParams(location.search).get('query') || '';
    var template = '<p>Hello NAME_SLOT!</p>';
    var rendered = template.replace('NAME_SLOT', function () { return q; });
    document.getElementById('out').innerHTML = rendered;
  </script>
  </body></html>"
end
