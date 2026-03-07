def load_history_state_xss
  Xssmaze.push("history-state-level1", "/history-state/level1/?seed=a", "history.replaceState bootstrap + innerHTML")
  maze_get "/history-state/level1/" do |_|
    "<div id='output'></div>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed) {
        history.replaceState(seed, '', location.pathname);
      }

      const state = history.state || '';
      document.getElementById('output').innerHTML = state;
    </script>"
  end

  Xssmaze.push("history-state-level2", "/history-state/level2/?seed=a", "history.replaceState object bootstrap + srcdoc sink")
  maze_get "/history-state/level2/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const url = new URL(location.href);
      const seed = url.searchParams.get('seed');
      if (seed) {
        history.replaceState({ html: seed }, '', location.pathname);
      }

      const state = history.state || {};
      document.getElementById('preview').setAttribute('srcdoc', state.html || '');
    </script>"
  end
end
