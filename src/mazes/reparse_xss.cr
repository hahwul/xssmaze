def load_reparse_xss
  Xssmaze.push("reparse-level1", "/reparse/level1/?query=a", "URLSearchParams clone + synthetic URL reparse + innerHTML")
  maze_get "/reparse/level1/" do |_|
    "<div id='output'></div>
    <script>
      const current = new URL(location.href);
      const cloned = new URLSearchParams(current.searchParams.toString());
      const replay = new URL(location.pathname + '?' + cloned.toString(), location.origin);
      const query = replay.searchParams.get('query') || '';
      document.getElementById('output').innerHTML = query;
    </script>"
  end

  Xssmaze.push("reparse-level2", "/reparse/level2/?blob=query=a", "nested querystring reparse + template.content clone")
  maze_get "/reparse/level2/" do |_|
    "<div id='output'></div>
    <template id='wrapper'></template>
    <script>
      const outer = new URL(location.href).searchParams;
      const blob = outer.get('blob') || '';
      const nested = new URLSearchParams(blob.charAt(0) == '?' ? blob.slice(1) : blob);
      const query = nested.get('query') || '';
      const wrapper = document.getElementById('wrapper');
      wrapper.innerHTML = `<article class='card'>${query}</article>`;
      document.getElementById('output').appendChild(wrapper.content.cloneNode(true));
    </script>"
  end

  Xssmaze.push("reparse-level3", "/reparse/level3/?query=a", "URLSearchParams HTML wrapper + srcdoc reparse")
  maze_get "/reparse/level3/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const current = new URL(location.href);
      const staged = new URLSearchParams();
      staged.set('html', `<section data-flow='reparse'>${current.searchParams.get('query') || ''}</section>`);
      const replay = new URLSearchParams(staged.toString());
      document.getElementById('preview').setAttribute(
        'srcdoc',
        `<!doctype html><html><body>${replay.get('html') || ''}</body></html>`
      );
    </script>"
  end

  Xssmaze.push("reparse-level4", "/reparse/level4/?blob=html=a", "nested blob reparse + srcdoc wrapper")
  maze_get "/reparse/level4/" do |_|
    "<iframe id='preview'></iframe>
    <script>
      const outer = new URL(location.href).searchParams;
      const blob = outer.get('blob') || '';
      const nested = new URLSearchParams(blob.charAt(0) == '?' ? blob.slice(1) : blob);
      const html = nested.get('html') || '';
      document.getElementById('preview').setAttribute(
        'srcdoc',
        `<!doctype html><html><body><article class='nested'>${html}</article></body></html>`
      );
    </script>"
  end

  Xssmaze.push("reparse-level5", "/reparse/level5/?blob=outer=query=a", "double nested querystring reparse + innerHTML")
  maze_get "/reparse/level5/" do |_|
    "<div id='output'></div>
    <script>
      const current = new URL(location.href).searchParams;
      const blob = current.get('blob') || '';
      const first = new URLSearchParams(blob.charAt(0) == '?' ? blob.slice(1) : blob);
      const outer = first.get('outer') || '';
      const second = new URLSearchParams(outer.charAt(0) == '?' ? outer.slice(1) : outer);
      const query = second.get('query') || '';
      document.getElementById('output').innerHTML = query;
    </script>"
  end
end
