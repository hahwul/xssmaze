def load_stream_xss
  Xssmaze.push("stream-level1", "/stream/level1/?seed=a", "EventSource message event + innerHTML")
  get "/stream/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const source = new EventSource('/map/text');

      source.onmessage = function(event) {
        document.getElementById('output').innerHTML = event.data;
      };

      if (seed) {
        source.dispatchEvent(new MessageEvent('message', { data: seed }));
      }
    </script>"
  end
  get "/stream/level1" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const source = new EventSource('/map/text');

      source.onmessage = function(event) {
        document.getElementById('output').innerHTML = event.data;
      };

      if (seed) {
        source.dispatchEvent(new MessageEvent('message', { data: seed }));
      }
    </script>"
  end

  Xssmaze.push("stream-level2", "/stream/level2/?seed=a", "WebSocket message event + JSON relay + srcdoc")
  get "/stream/level2/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const socket = new WebSocket('wss://example.invalid/xssmaze');

      socket.addEventListener('message', function(event) {
        const data = JSON.parse(event.data);
        document.getElementById('preview').setAttribute('srcdoc', data.html || '');
      });

      if (seed) {
        socket.dispatchEvent(
          new MessageEvent('message', {
            data: JSON.stringify({ html: seed }),
          })
        );
      }
    </script>"
  end
  get "/stream/level2" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const socket = new WebSocket('wss://example.invalid/xssmaze');

      socket.addEventListener('message', function(event) {
        const data = JSON.parse(event.data);
        document.getElementById('preview').setAttribute('srcdoc', data.html || '');
      });

      if (seed) {
        socket.dispatchEvent(
          new MessageEvent('message', {
            data: JSON.stringify({ html: seed }),
          })
        );
      }
    </script>"
  end

  Xssmaze.push("stream-level3", "/stream/level3/?seed=a", "SharedWorker message relay + createContextualFragment")
  get "/stream/level3/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const workerSource = `
        onconnect = function(event) {
          const port = event.ports[0];
          port.onmessage = function(messageEvent) {
            port.postMessage(messageEvent.data);
          };
          port.start();
        };
      `;
      const workerUrl = URL.createObjectURL(new Blob([workerSource], { type: 'text/javascript' }));
      const shared = new SharedWorker(workerUrl);
      shared.port.onmessage = function(event) {
        const range = document.createRange();
        const fragment = range.createContextualFragment(event.data);
        document.getElementById('output').appendChild(fragment);
      };
      shared.port.start();

      if (seed) {
        shared.port.postMessage(seed);
      }
    </script>"
  end
  get "/stream/level3" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const workerSource = `
        onconnect = function(event) {
          const port = event.ports[0];
          port.onmessage = function(messageEvent) {
            port.postMessage(messageEvent.data);
          };
          port.start();
        };
      `;
      const workerUrl = URL.createObjectURL(new Blob([workerSource], { type: 'text/javascript' }));
      const shared = new SharedWorker(workerUrl);
      shared.port.onmessage = function(event) {
        const range = document.createRange();
        const fragment = range.createContextualFragment(event.data);
        document.getElementById('output').appendChild(fragment);
      };
      shared.port.start();

      if (seed) {
        shared.port.postMessage(seed);
      }
    </script>"
  end
end
