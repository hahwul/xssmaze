def load_storage_event_xss
  Xssmaze.push("storage-event-level1", "/storage-event/level1/?seed=a", "storage event newValue + innerHTML")
  maze_get "/storage-event/level1/" do |_|
    "<div id='output'></div>
    <iframe id='listener' style='display:none'></iframe>
    <script>
      const url = new URL(location.href);
      const isListener = url.searchParams.get('listener') === '1';
      const seed = url.searchParams.get('seed') || '';
      const key = 'xssmaze:storage-event:level1';

      if (isListener) {
        window.addEventListener('storage', function(event) {
          if (event.key === key) {
            document.getElementById('output').innerHTML = event.newValue || '';
          }
        });
      } else {
        const listenerUrl = new URL(location.href);
        listenerUrl.searchParams.delete('seed');
        listenerUrl.searchParams.set('listener', '1');
        document.getElementById('listener').src =
          listenerUrl.pathname + '?' + listenerUrl.searchParams.toString();

        if (seed) {
          setTimeout(function() {
            localStorage.setItem(key, seed);
          }, 150);
        }
      }
    </script>"
  end

  Xssmaze.push("storage-event-level2", "/storage-event/level2/?seed=a", "storage event oldValue + srcdoc")
  maze_get "/storage-event/level2/" do |_|
    "<iframe id='preview'></iframe>
    <iframe id='listener' style='display:none'></iframe>
    <script>
      const url = new URL(location.href);
      const isListener = url.searchParams.get('listener') === '1';
      const seed = url.searchParams.get('seed') || '';
      const key = 'xssmaze:storage-event:level2';

      if (isListener) {
        window.addEventListener('storage', function(event) {
          if (event.key === key && event.oldValue) {
            document.getElementById('preview').setAttribute(
              'srcdoc',
              '<!doctype html><html><body>' + event.oldValue + '</body></html>'
            );
          }
        });
      } else {
        const listenerUrl = new URL(location.href);
        listenerUrl.searchParams.delete('seed');
        listenerUrl.searchParams.set('listener', '1');
        document.getElementById('listener').src =
          listenerUrl.pathname + '?' + listenerUrl.searchParams.toString();

        if (seed) {
          setTimeout(function() {
            localStorage.setItem(key, seed);
            localStorage.setItem(key, '<p>rotated</p>');
          }, 150);
        }
      }
    </script>"
  end
end
