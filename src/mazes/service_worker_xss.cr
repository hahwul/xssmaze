def load_service_worker_xss
  Xssmaze.push("service-worker-level1", "/service-worker/level1/?seed=a", "ServiceWorker message bootstrap + innerHTML")
  get "/service-worker/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.addEventListener('message', function(event) {
          document.getElementById('output').innerHTML = event.data;
        });

        if (seed) {
          navigator.serviceWorker.dispatchEvent(
            new MessageEvent('message', { data: seed })
          );
        }
      }
    </script>"
  end
  get "/service-worker/level1" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.addEventListener('message', function(event) {
          document.getElementById('output').innerHTML = event.data;
        });

        if (seed) {
          navigator.serviceWorker.dispatchEvent(
            new MessageEvent('message', { data: seed })
          );
        }
      }
    </script>"
  end

  Xssmaze.push("service-worker-level2", "/service-worker/level2/?seed=a", "ServiceWorker message JSON relay + srcdoc")
  get "/service-worker/level2/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.addEventListener('message', function(event) {
          const data = JSON.parse(event.data);
          document.getElementById('preview').setAttribute('srcdoc', data.html || '');
        });

        if (seed) {
          navigator.serviceWorker.dispatchEvent(
            new MessageEvent('message', {
              data: JSON.stringify({ html: seed }),
            })
          );
        }
      }
    </script>"
  end
  get "/service-worker/level2" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.addEventListener('message', function(event) {
          const data = JSON.parse(event.data);
          document.getElementById('preview').setAttribute('srcdoc', data.html || '');
        });

        if (seed) {
          navigator.serviceWorker.dispatchEvent(
            new MessageEvent('message', {
              data: JSON.stringify({ html: seed }),
            })
          );
        }
      }
    </script>"
  end
end
