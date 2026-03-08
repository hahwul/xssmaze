def load_opener_xss
  Xssmaze.push("opener-level1", "/opener/level1/?seed=a", "window.opener bootstrap + innerHTML", "GET", ["seed"])
  maze_get "/opener/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed && !window.opener) {
        window.name = seed;
        window.open(location.pathname, 'xssmaze:opener:level1');
      } else if (window.opener) {
        document.getElementById('output').innerHTML = window.opener.name || '';
      }
    </script>"
  end

  Xssmaze.push("opener-level2", "/opener/level2/?seed=a", "window.opener object relay + srcdoc", "GET", ["seed"])
  maze_get "/opener/level2/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed && !window.opener) {
        window.__xssmazePreview = { html: seed };
        window.open(location.pathname, 'xssmaze:opener:level2');
      } else if (window.opener) {
        const bootstrap = window.opener.__xssmazePreview || {};
        document.getElementById('preview').setAttribute('srcdoc', bootstrap.html || '');
      }
    </script>"
  end
end
