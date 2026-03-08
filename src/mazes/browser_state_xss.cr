def load_browser_state_xss
  Xssmaze.push("browser-state-level1", "/browser-state/level1/?seed=a", "window.name bootstrap + innerHTML", "GET", ["seed"])
  maze_get "/browser-state/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed) {
        window.name = seed;
        url.searchParams.delete('seed');
        const nextSearch = url.searchParams.toString();
        location.replace(url.pathname + (nextSearch ? '?' + nextSearch : ''));
      } else {
        document.getElementById('output').innerHTML = window.name;
      }
    </script>"
  end

  Xssmaze.push("browser-state-level2", "/browser-state/level2/?seed=a", "localStorage relay + insertAdjacentHTML", "GET", ["seed"])
  maze_get "/browser-state/level2/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed) {
        localStorage.setItem('xssmaze:browser-state:level2', seed);
        url.searchParams.delete('seed');
        const nextSearch = url.searchParams.toString();
        location.replace(url.pathname + (nextSearch ? '?' + nextSearch : ''));
      } else {
        const stored = localStorage.getItem('xssmaze:browser-state:level2') || '';
        document.getElementById('output').insertAdjacentHTML('beforeend', stored);
      }
    </script>"
  end

  Xssmaze.push("browser-state-level3", "/browser-state/level3/?seed=a", "sessionStorage relay + createContextualFragment", "GET", ["seed"])
  maze_get "/browser-state/level3/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed) {
        sessionStorage.setItem('xssmaze:browser-state:level3', seed);
        url.searchParams.delete('seed');
        const nextSearch = url.searchParams.toString();
        location.replace(url.pathname + (nextSearch ? '?' + nextSearch : ''));
      } else {
        const stored = sessionStorage.getItem('xssmaze:browser-state:level3') || '';
        const range = document.createRange();
        const fragment = range.createContextualFragment(stored);
        document.getElementById('output').appendChild(fragment);
      }
    </script>"
  end

  Xssmaze.push("browser-state-level4", "/browser-state/level4/?seed=a", "postMessage relay + structured data + innerHTML", "GET", ["seed"])
  maze_get "/browser-state/level4/" do |_|
    "<div id='output'></div>
    <iframe id='relay' sandbox='allow-scripts' style='display:none'></iframe>
    <script>
      window.addEventListener('message', function(event) {
        const html = event.data && event.data.html ? event.data.html : '';
        document.getElementById('output').innerHTML = html;
      });

      const seed = new URL(location.href).searchParams.get('seed');
      if (seed) {
        const relay = document.getElementById('relay');
        relay.srcdoc = `<script>parent.postMessage({html: ${JSON.stringify(seed)}}, '*')<\\/script>`;
      }
    </script>"
  end

  Xssmaze.push("browser-state-level5", "/browser-state/level5/?seed=a", "document.referrer bootstrap + document.write", "GET", ["seed"])
  maze_get "/browser-state/level5/" do |_|
    "<div id='output'></div>
    <iframe id='relay' style='display:none'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      const child = url.searchParams.get('child');
      if (child === '1') {
        document.write(document.referrer);
      } else if (seed) {
        const relayUrl = new URL(location.href);
        relayUrl.searchParams.delete('seed');
        relayUrl.searchParams.set('child', '1');
        document.getElementById('relay').src = relayUrl.pathname + '?' + relayUrl.searchParams.toString();
      } else {
        document.write(document.referrer);
      }
    </script>"
  end
end
