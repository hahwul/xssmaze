def load_channel_xss
  Xssmaze.push("channel-level1", "/channel/level1/?seed=a", "BroadcastChannel relay + innerHTML")
  get "/channel/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const receiver = new BroadcastChannel('xssmaze:channel:level1');
      receiver.onmessage = function(event) {
        document.getElementById('output').innerHTML = event.data;
      };

      if (seed) {
        const sender = new BroadcastChannel('xssmaze:channel:level1');
        sender.postMessage(seed);
      }
    </script>"
  end
  get "/channel/level1" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const receiver = new BroadcastChannel('xssmaze:channel:level1');
      receiver.onmessage = function(event) {
        document.getElementById('output').innerHTML = event.data;
      };

      if (seed) {
        const sender = new BroadcastChannel('xssmaze:channel:level1');
        sender.postMessage(seed);
      }
    </script>"
  end

  Xssmaze.push("channel-level2", "/channel/level2/?seed=a", "MessageChannel port relay + insertAdjacentHTML")
  get "/channel/level2/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const channel = new MessageChannel();
      channel.port1.onmessage = function(event) {
        document.getElementById('output').insertAdjacentHTML('beforeend', event.data);
      };

      if (seed) {
        channel.port2.postMessage(seed);
      }
    </script>"
  end
  get "/channel/level2" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const channel = new MessageChannel();
      channel.port1.onmessage = function(event) {
        document.getElementById('output').insertAdjacentHTML('beforeend', event.data);
      };

      if (seed) {
        channel.port2.postMessage(seed);
      }
    </script>"
  end

  Xssmaze.push("channel-level3", "/channel/level3/?seed=a", "Worker message relay + createContextualFragment")
  get "/channel/level3/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const workerSource = `
        self.onmessage = function(event) {
          self.postMessage(event.data);
        };
      `;
      const workerUrl = URL.createObjectURL(new Blob([workerSource], { type: 'text/javascript' }));
      const worker = new Worker(workerUrl);
      worker.onmessage = function(event) {
        const range = document.createRange();
        const fragment = range.createContextualFragment(event.data);
        document.getElementById('output').appendChild(fragment);
      };

      if (seed) {
        worker.postMessage(seed);
      }
    </script>"
  end
  get "/channel/level3" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const workerSource = `
        self.onmessage = function(event) {
          self.postMessage(event.data);
        };
      `;
      const workerUrl = URL.createObjectURL(new Blob([workerSource], { type: 'text/javascript' }));
      const worker = new Worker(workerUrl);
      worker.onmessage = function(event) {
        const range = document.createRange();
        const fragment = range.createContextualFragment(event.data);
        document.getElementById('output').appendChild(fragment);
      };

      if (seed) {
        worker.postMessage(seed);
      }
    </script>"
  end

  Xssmaze.push("channel-level4", "/channel/level4/?seed=a", "BroadcastChannel JSON relay + srcdoc sink")
  get "/channel/level4/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const receiver = new BroadcastChannel('xssmaze:channel:level4');
      receiver.onmessage = function(event) {
        const data = JSON.parse(event.data);
        document.getElementById('preview').setAttribute('srcdoc', data.html);
      };

      if (seed) {
        const sender = new BroadcastChannel('xssmaze:channel:level4');
        sender.postMessage(JSON.stringify({ html: seed }));
      }
    </script>"
  end
  get "/channel/level4" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const receiver = new BroadcastChannel('xssmaze:channel:level4');
      receiver.onmessage = function(event) {
        const data = JSON.parse(event.data);
        document.getElementById('preview').setAttribute('srcdoc', data.html);
      };

      if (seed) {
        const sender = new BroadcastChannel('xssmaze:channel:level4');
        sender.postMessage(JSON.stringify({ html: seed }));
      }
    </script>"
  end
end
