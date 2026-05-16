# Static CSS/JS for the index page. Served separately from the catalog HTML
# so browsers can cache them independently.
module Xssmaze::Assets
  INDEX_CSS = <<-CSS
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #ffffff;
    }
    .header {
      max-width: 1200px;
      margin: 0 auto 20px;
    }
    h1 { color: #333; margin-bottom: 10px; }
    .description { color: #666; line-height: 1.6; margin-bottom: 10px; }
    .description code {
      background-color: #f4f4f4;
      color: #c7254e;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
    }
    .stats {
      display: flex;
      gap: 18px;
      margin: 14px 0;
      flex-wrap: wrap;
    }
    .stats .stat {
      background: #f5f5f5;
      padding: 6px 12px;
      border-radius: 4px;
      font-size: 0.9em;
      color: #333;
    }
    .stats .stat strong { color: #0366d6; }
    .controls {
      display: flex;
      gap: 10px;
      margin-top: 16px;
      align-items: center;
      flex-wrap: wrap;
    }
    #search {
      flex: 1;
      min-width: 240px;
      padding: 8px 12px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 14px;
    }
    .map-links {
      margin-top: 14px;
      padding-top: 14px;
      border-top: 1px solid #e0e0e0;
      font-size: 0.92em;
    }
    .map-links a {
      color: #0366d6;
      text-decoration: none;
      margin-right: 12px;
    }
    .map-links a:hover { text-decoration: underline; }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 30px 60px;
      background-color: #F5F5F5;
      border-radius: 8px;
    }
    .list {
      list-style: none;
      padding: 0;
      margin: 0;
      line-height: 1.1;
    }
    .list li {
      padding: 0.2em 0 0.2em 1.2em;
      margin: 0;
      position: relative;
      font-weight: 600;
      color: #333;
    }
    .list li:before {
      content: '';
      width: 0.5em;
      height: 0.5em;
      position: absolute;
      border-radius: 0.5em;
      background-color: #666;
      display: block;
      left: -0.2em;
      top: 0.4em;
    }
    .list li + li:after {
      content: '';
      display: block;
      width: 2px;
      height: 1em;
      padding: 0.2em 0;
      background-color: #666;
      position: absolute;
      left: 0;
      top: -0.75em;
    }
    .list li > .list { position: relative; }
    .list li > .list:before {
      content: '';
      display: block;
      width: 1.5em;
      height: 2px;
      background-color: #666;
      position: absolute;
      left: -1.35em;
      top: -0.1em;
      transform: rotate(45deg);
    }
    .list li > .list:after {
      content: '';
      display: block;
      width: 2px;
      height: 115%;
      background-color: #666;
      position: absolute;
      left: -1.2em;
      top: -0.5em;
    }
    .list li:last-of-type > .list:after { content: none; }
    .list li > .list li {
      font-weight: normal;
      font-size: 0.95em;
    }
    .list li > .list li a {
      color: #0366d6;
      text-decoration: none;
    }
    .list li > .list li a:hover { text-decoration: underline; }
    .count {
      color: #888;
      font-weight: normal;
      font-size: 0.85em;
    }
    .method {
      display: inline-block;
      font-size: 0.7em;
      font-weight: 700;
      color: #666;
      background: #e7e7e7;
      padding: 1px 6px;
      border-radius: 3px;
      margin-left: 4px;
    }
    .hidden { display: none !important; }
    @media (max-width: 768px) {
      .container { padding: 20px 16px; margin: 0 8px; }
      body { padding: 10px; }
    }
  CSS

  INDEX_JS = <<-JS
    (function () {
      var input = document.getElementById('search');
      if (!input) return;
      var mazes = document.querySelectorAll('.maze');
      var cats = document.querySelectorAll('.cat');
      var totalEl = document.getElementById('stat-visible');
      input.addEventListener('input', function () {
        var q = input.value.toLowerCase().trim();
        var visible = 0;
        mazes.forEach(function (el) {
          var name = el.getAttribute('data-name') || '';
          var desc = el.getAttribute('data-desc') || '';
          var match = q === '' || name.indexOf(q) !== -1 || desc.indexOf(q) !== -1;
          el.classList.toggle('hidden', !match);
          if (match) visible++;
        });
        cats.forEach(function (cat) {
          var any = cat.querySelectorAll('.maze:not(.hidden)').length > 0;
          cat.classList.toggle('hidden', !any);
        });
        if (totalEl) totalEl.textContent = visible;
      });
    })();
  JS
end
