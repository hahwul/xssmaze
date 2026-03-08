def load_referrer_xss
  Xssmaze.push("referrer-level1", "/referrer/level1/?seed=a", "document.referrer reparse + createContextualFragment", "GET", ["seed"])
  maze_get "/referrer/level1/" do |_|
    "<div id='output'></div>
    <script>
      const referrer = document.referrer;
      const encoded = (referrer.split('seed=')[1] || '').split('&')[0] || referrer;
      const html = decodeURIComponent(encoded.replace(/\\+/g, '%20'));
      const range = document.createRange();
      const fragment = range.createContextualFragment(html);
      document.getElementById('output').appendChild(fragment);
    </script>"
  end

  Xssmaze.push("referrer-level2", "/referrer/level2/?seed=a", "document.referrer reparse + template innerHTML clone", "GET", ["seed"])
  maze_get "/referrer/level2/" do |_|
    "<div id='output'></div>
    <script>
      const referrer = document.referrer;
      const encoded = (referrer.split('seed=')[1] || '').split('&')[0] || referrer;
      const html = decodeURIComponent(encoded.replace(/\\+/g, '%20'));
      const template = document.createElement('template');
      template.innerHTML = html;
      document.getElementById('output').appendChild(template.content.cloneNode(true));
    </script>"
  end
end
