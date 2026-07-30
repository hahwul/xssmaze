# Client-side persisted-state DOM XSS. Web storage, cookies, and the
# history state object are all recognized DOM-XSS *sources*: apps routinely
# stash a preference / draft / search term / profile client-side and then
# render it raw on the next visit. Each level seeds the store from the URL
# (so a single navigation triggers it for verification) and then reads the
# value back out of the store into an HTML sink — exercising a scanner's
# ability to treat storage/cookie/history reads as tainted.

# Level 1: localStorage value reflected via innerHTML.
Xssmaze.push("clientstate-level1", "/clientstate/level1/?pref=a", "localStorage value (seeded from URL) reflected via innerHTML", "GET", ["pref"],
  vuln: "dom", sources: ["localStorage"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/clientstate/level1/" do |_env|
  "<html><body>
  <h1>User Preference</h1>
  <div id='greeting'></div>
  <script>
    var pref = new URLSearchParams(location.search).get('pref');
    if (pref !== null) { localStorage.setItem('pref', pref); }
    // Stored preference rendered raw on every visit.
    document.getElementById('greeting').innerHTML = localStorage.getItem('pref') || 'Welcome';
  </script>
  </body></html>"
end

# Level 2: sessionStorage value written via document.write.
Xssmaze.push("clientstate-level2", "/clientstate/level2/?q=a", "sessionStorage value (seeded from URL) written via document.write", "GET", ["q"],
  vuln: "dom", sources: ["sessionStorage"], sinks: ["document.write"], delivery: ["query"])
maze_get "/clientstate/level2/" do |_env|
  "<html><body>
  <h1>Recent Search</h1>
  <script>
    var q = new URLSearchParams(location.search).get('q');
    if (q !== null) { sessionStorage.setItem('lastQuery', q); }
    var last = sessionStorage.getItem('lastQuery');
    if (last) { document.write('You searched for: ' + last); }
  </script>
  </body></html>"
end

# Level 3: localStorage draft injected via insertAdjacentHTML.
Xssmaze.push("clientstate-level3", "/clientstate/level3/?draft=a", "localStorage draft (seeded from URL) injected via insertAdjacentHTML", "GET", ["draft"],
  vuln: "dom", sources: ["localStorage"], sinks: ["insertAdjacentHTML"], delivery: ["query"])
maze_get "/clientstate/level3/" do |_env|
  "<html><body>
  <h1>Autosaved Draft</h1>
  <div id='editor'></div>
  <script>
    var draft = new URLSearchParams(location.search).get('draft');
    if (draft !== null) { localStorage.setItem('draft', draft); }
    var saved = localStorage.getItem('draft');
    if (saved) { document.getElementById('editor').insertAdjacentHTML('beforeend', saved); }
  </script>
  </body></html>"
end

# Level 4: document.cookie value reflected via innerHTML.
Xssmaze.push("clientstate-level4", "/clientstate/level4/?theme=a", "document.cookie value (seeded from URL) reflected via innerHTML", "GET", ["theme"],
  vuln: "dom", sources: ["document.cookie"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/clientstate/level4/" do |_env|
  "<html><body>
  <h1>Theme</h1>
  <div id='banner'></div>
  <script>
    var theme = new URLSearchParams(location.search).get('theme');
    if (theme !== null) { document.cookie = 'theme=' + theme; }
    // Read the theme back out of the cookie jar and render it.
    var m = document.cookie.match(/(?:^|; )theme=([^;]*)/);
    if (m) { document.getElementById('banner').innerHTML = 'Theme: ' + m[1]; }
  </script>
  </body></html>"
end

# Level 5: history.state value reflected via innerHTML.
Xssmaze.push("clientstate-level5", "/clientstate/level5/?note=a", "history.state value (seeded from URL) reflected via innerHTML", "GET", ["note"],
  vuln: "dom", sources: ["history.state"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/clientstate/level5/" do |_env|
  "<html><body>
  <h1>Sticky Note</h1>
  <div id='note'></div>
  <script>
    var note = new URLSearchParams(location.search).get('note');
    if (note !== null) { history.replaceState({ note: note }, ''); }
    var st = history.state;
    if (st && st.note) { document.getElementById('note').innerHTML = st.note; }
  </script>
  </body></html>"
end

# Level 6: localStorage JSON profile field reflected via innerHTML.
Xssmaze.push("clientstate-level6", "/clientstate/level6/?bio=a", "localStorage JSON profile (seeded from URL) field reflected via innerHTML", "GET", ["bio"],
  vuln: "dom", sources: ["localStorage"], sinks: ["innerHTML"], delivery: ["query"], note: "value is laundered through a JSON.stringify / JSON.parse round-trip")
maze_get "/clientstate/level6/" do |_env|
  "<html><body>
  <h1>Profile</h1>
  <div id='bio'></div>
  <script>
    var bio = new URLSearchParams(location.search).get('bio');
    if (bio !== null) { localStorage.setItem('profile', JSON.stringify({bio: bio})); }
    var raw = localStorage.getItem('profile');
    if (raw) {
      var profile = JSON.parse(raw);
      document.getElementById('bio').innerHTML = profile.bio || '';
    }
  </script>
  </body></html>"
end
