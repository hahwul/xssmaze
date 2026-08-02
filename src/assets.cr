# Static CSS/JS for the index page. Served separately from the catalog HTML
# so browsers can cache them independently.
#
# Visual language is "ember": the maze at night. A warm near-black ground
# (brown-shifted, not blue-shifted, so it never reads as generic dark mode)
# carrying a single ember accent that only lights the corridor the cursor is
# in. Nested levels hang off hairline corridor rails rather than bullets.
#
# Every colour is a custom property so the two themes stay in lockstep;
# components never reference a raw hex value. Both themes are checked against
# WCAG AA: --text/--muted/--dim/--ember/--inert all clear 4.5:1 on --bg, and
# --edge (interactive control borders) clears the 3:1 of WCAG 1.4.11. --rail
# is deliberately below that: it draws decorative structure, never a boundary
# the user has to perceive.
module Xssmaze::Assets
  INDEX_CSS = <<-CSS
    :root {
      --bg: #ebe8e4;
      --bg-blur: rgba(235, 232, 228, .88);
      --surface: #f5f3f0;
      --rail: #cdc7c0;
      --edge: #87837f;
      --text: #1a1816;
      --muted: #514b46;
      --dim: #6e6862;
      --ember: #9f5518;
      --ember-sf: rgba(159, 85, 24, .10);
      --ember-line: rgba(159, 85, 24, .42);
      --inert: #5d6a74;
      --inert-line: rgba(93, 106, 116, .45);
      --radius: 3px;
      --bar-h: 53px;
      --sans: ui-sans-serif, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      --mono: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
      color-scheme: light;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #100f0e;
        --bg-blur: rgba(16, 15, 14, .88);
        --surface: #191715;
        --rail: #322d28;
        --edge: #635f5c;
        --text: #e8e2d9;
        --muted: #a39c92;
        --dim: #807a74;
        --ember: #d9853b;
        --ember-sf: rgba(217, 133, 59, .12);
        --ember-line: rgba(217, 133, 59, .42);
        --inert: #7f8f9a;
        --inert-line: rgba(127, 143, 154, .45);
        color-scheme: dark;
      }
    }
    :root[data-theme="dark"] {
      --bg: #100f0e;
      --bg-blur: rgba(16, 15, 14, .88);
      --surface: #191715;
      --rail: #322d28;
      --edge: #635f5c;
      --text: #e8e2d9;
      --muted: #a39c92;
      --dim: #807a74;
      --ember: #d9853b;
      --ember-sf: rgba(217, 133, 59, .12);
      --ember-line: rgba(217, 133, 59, .42);
      --inert: #7f8f9a;
      --inert-line: rgba(127, 143, 154, .45);
      color-scheme: dark;
    }
    :root[data-theme="light"] {
      --bg: #ebe8e4;
      --bg-blur: rgba(235, 232, 228, .88);
      --surface: #f5f3f0;
      --rail: #cdc7c0;
      --edge: #87837f;
      --text: #1a1816;
      --muted: #514b46;
      --dim: #6e6862;
      --ember: #9f5518;
      --ember-sf: rgba(159, 85, 24, .10);
      --ember-line: rgba(159, 85, 24, .42);
      --inert: #5d6a74;
      --inert-line: rgba(93, 106, 116, .45);
      color-scheme: light;
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: var(--sans);
      font-size: 15px;
      line-height: 1.55;
      -webkit-font-smoothing: antialiased;
    }

    a { color: inherit; }
    :focus-visible {
      outline: 2px solid var(--ember);
      outline-offset: 2px;
      border-radius: var(--radius);
    }

    .shell { max-width: 1240px; margin: 0 auto; padding: 0 28px; }

    /* ---------- header ---------- */

    .top { padding: 44px 0 26px; }

    .brandline {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 32px;
      flex-wrap: wrap;
    }

    .brand { display: flex; align-items: center; gap: 14px; }

    .mark { width: 38px; height: 38px; flex: none; color: var(--ember); }
    .mark path {
      stroke: currentColor;
      stroke-width: 1.6;
      fill: none;
      stroke-linecap: square;
      stroke-linejoin: miter;
      stroke-dasharray: 120;
      stroke-dashoffset: 120;
      animation: thread 1.5s cubic-bezier(.65, 0, .35, 1) forwards;
    }
    @keyframes thread { to { stroke-dashoffset: 0; } }
    @media (prefers-reduced-motion: reduce) {
      .mark path { animation: none; stroke-dashoffset: 0; }
    }

    .wordmark {
      margin: 0;
      font-size: 29px;
      font-weight: 620;
      letter-spacing: -.017em;
      line-height: 1.1;
    }
    .subline {
      margin: 2px 0 0;
      font-size: 10.5px;
      letter-spacing: .17em;
      text-transform: uppercase;
      color: var(--dim);
    }

    .readout {
      display: flex;
      gap: 26px;
      padding-top: 4px;
      font-family: var(--mono);
      font-variant-numeric: tabular-nums;
    }
    .readout div { text-align: right; }
    .readout b {
      display: block;
      font-size: 21px;
      font-weight: 500;
      letter-spacing: -.02em;
      line-height: 1.15;
    }
    .readout span {
      font-size: 10.5px;
      letter-spacing: .1em;
      text-transform: uppercase;
      color: var(--dim);
    }

    .lede { margin: 22px 0 0; max-width: 60ch; color: var(--muted); font-size: 15.5px; }

    .params {
      margin: 14px 0 0;
      font-size: 12.5px;
      color: var(--dim);
      display: flex;
      align-items: baseline;
      gap: 7px;
      flex-wrap: wrap;
    }
    .params code {
      font-family: var(--mono);
      color: var(--muted);
      background: var(--surface);
      border: 1px solid var(--rail);
      border-radius: var(--radius);
      padding: 1px 6px;
      font-size: 11.5px;
    }

    /* ---------- control bar ---------- */

    .bar {
      position: sticky;
      top: 0;
      z-index: 20;
      margin-top: 30px;
      background: var(--bg-blur);
      backdrop-filter: blur(10px);
      -webkit-backdrop-filter: blur(10px);
      border-top: 1px solid var(--rail);
      border-bottom: 1px solid var(--rail);
    }
    @media (prefers-reduced-transparency: reduce) {
      .bar { background: var(--bg); backdrop-filter: none; -webkit-backdrop-filter: none; }
    }

    .bar-in {
      max-width: 1240px;
      margin: 0 auto;
      padding: 11px 28px;
      display: flex;
      align-items: center;
      gap: 12px;
      flex-wrap: wrap;
    }

    /* Interactive controls use --edge, not the lighter corridor hairline:
       a control boundary has to clear WCAG 1.4.11 (3:1) where a decorative
       rail does not. */
    #search {
      flex: 1 1 260px;
      min-width: 0;
      background: var(--surface);
      border: 1px solid var(--edge);
      border-radius: var(--radius);
      color: var(--text);
      padding: 8px 11px;
      font-family: var(--mono);
      font-size: 13px;
    }
    #search::placeholder { color: var(--dim); }
    #search:focus {
      outline: none;
      border-color: var(--ember);
      box-shadow: 0 0 0 3px var(--ember-sf);
    }

    .chips { display: flex; gap: 6px; flex-wrap: wrap; }
    .chip {
      appearance: none;
      background: transparent;
      border: 1px solid var(--edge);
      border-radius: var(--radius);
      color: var(--muted);
      padding: 6px 10px;
      font-family: var(--mono);
      font-size: 11px;
      letter-spacing: .045em;
      cursor: pointer;
      transition: color .14s, border-color .14s, background .14s;
    }
    .chip:hover { color: var(--text); border-color: var(--muted); }
    .chip[aria-pressed="true"] {
      color: var(--ember);
      border-color: var(--ember);
      background: var(--ember-sf);
    }

    .tally {
      margin: 0 0 0 auto;
      font-family: var(--mono);
      font-variant-numeric: tabular-nums;
      font-size: 11.5px;
      letter-spacing: .04em;
      color: var(--dim);
      white-space: nowrap;
    }
    .tally b { color: var(--text); font-weight: 500; }

    .theme {
      appearance: none;
      background: transparent;
      border: 1px solid var(--edge);
      border-radius: var(--radius);
      color: var(--muted);
      width: 30px;
      height: 30px;
      cursor: pointer;
      font-size: 13px;
      line-height: 1;
      flex: none;
    }
    .theme:hover { color: var(--text); border-color: var(--muted); }

    /* ---------- layout ---------- */

    .layout {
      display: grid;
      grid-template-columns: 1fr;
      gap: 34px;
      padding: 30px 0 70px;
    }
    @media (min-width: 1040px) {
      .layout { grid-template-columns: 186px 1fr; gap: 46px; }
    }

    .rail-nav { display: none; }
    @media (min-width: 1040px) {
      .rail-nav {
        display: block;
        position: sticky;
        top: calc(var(--bar-h) + 20px);
        align-self: start;
        max-height: calc(100dvh - var(--bar-h) - 46px);
        overflow-y: auto;
      }
    }
    .rail-nav h2 {
      margin: 0 0 12px;
      font-size: 10.5px;
      letter-spacing: .13em;
      text-transform: uppercase;
      color: var(--dim);
      font-weight: 500;
    }
    .rail-nav a {
      display: flex;
      justify-content: space-between;
      gap: 10px;
      padding: 4px 0;
      font-family: var(--mono);
      font-size: 12.5px;
      color: var(--muted);
      text-decoration: none;
    }
    .rail-nav a:hover { color: var(--ember); }
    .rail-nav a i {
      font-style: normal;
      color: var(--dim);
      font-size: 11px;
      font-variant-numeric: tabular-nums;
    }

    /* ---------- corridor list ---------- */

    .cat { margin-bottom: 30px; }

    .cat-head {
      display: flex;
      align-items: baseline;
      gap: 10px;
      padding-bottom: 8px;
      border-bottom: 1px solid var(--rail);
    }
    .cat-head h2 {
      margin: 0;
      font-size: 13px;
      font-weight: 500;
      letter-spacing: .1em;
      text-transform: uppercase;
      color: var(--text);
    }
    .cat-head .count {
      font-family: var(--mono);
      font-variant-numeric: tabular-nums;
      font-size: 11.5px;
      color: var(--dim);
    }

    .rows {
      list-style: none;
      margin: 0;
      padding: 0 0 0 17px;
      border-left: 1px solid var(--rail);
    }

    .maze {
      position: relative;
      display: grid;
      grid-template-columns: minmax(0, 1fr);
      gap: 2px 14px;
      padding: 7px 0 7px 4px;
      align-items: baseline;
    }
    /* the corridor branch off the rail */
    .maze::before {
      content: '';
      position: absolute;
      left: -17px;
      top: 13px;
      width: 13px;
      height: 1px;
      background: var(--rail);
      transition: background .14s;
    }
    .maze:hover::before { background: var(--ember); }

    @media (min-width: 760px) {
      .maze {
        grid-template-columns: 27ch minmax(0, 1fr) auto;
        gap: 14px;
        padding: 5px 0 5px 4px;
      }
      .maze::before { top: 12px; }
    }

    .maze a {
      font-family: var(--mono);
      font-size: 12.5px;
      text-decoration: none;
      color: var(--text);
      justify-self: start;
      border-bottom: 1px solid transparent;
      overflow-wrap: anywhere;
      transition: color .14s, border-color .14s;
    }
    .maze a:hover { color: var(--ember); border-bottom-color: var(--ember); }

    .desc { color: var(--muted); font-size: 13.5px; min-width: 0; }

    .meta { display: flex; gap: 5px; flex-wrap: wrap; align-items: center; }
    .tag {
      font-family: var(--mono);
      font-size: 10px;
      letter-spacing: .05em;
      padding: 1px 5px;
      border-radius: var(--radius);
      border: 1px solid var(--rail);
      color: var(--dim);
      white-space: nowrap;
    }
    .tag.cls { color: var(--muted); }
    .tag.client { color: var(--ember); border-color: var(--ember-line); }
    .tag.method { color: var(--text); border-color: var(--edge); }

    /* Controls read as inert: a cool cast against the warm ground, so a true
       negative is legible as "not a target" without relying on colour alone
       (the class tag still spells it out). */
    .maze.control a { color: var(--inert); }
    .maze.control a:hover { color: var(--inert); border-bottom-color: var(--inert); }
    .maze.control:hover::before { background: var(--inert); }
    .maze.control .desc { color: var(--dim); }
    .maze.control .tag.cls { color: var(--inert); border-color: var(--inert-line); }

    .hidden { display: none !important; }

    .empty { padding: 46px 4px; color: var(--muted); }
    .empty b { display: block; color: var(--text); font-weight: 500; margin-bottom: 6px; }
    .empty code { font-family: var(--mono); color: var(--ember); }

    /* ---------- footer ---------- */

    .foot {
      border-top: 1px solid var(--rail);
      padding: 22px 0 60px;
      display: flex;
      gap: 8px 18px;
      flex-wrap: wrap;
      align-items: baseline;
    }
    .foot span {
      color: var(--dim);
      letter-spacing: .1em;
      text-transform: uppercase;
      font-size: 10.5px;
    }
    .foot a {
      font-family: var(--mono);
      font-size: 12px;
      color: var(--muted);
      text-decoration: none;
      border-bottom: 1px solid transparent;
    }
    .foot a:hover { color: var(--ember); border-bottom-color: var(--ember); }

    /* ---------- 404 ---------- */

    .notfound { padding: 90px 0 110px; max-width: 62ch; }
    .notfound h1 {
      margin: 0;
      font-size: 52px;
      font-weight: 620;
      letter-spacing: -.03em;
      line-height: 1;
    }
    .notfound p { margin: 20px 0 0; color: var(--muted); }
    .notfound .path {
      font-family: var(--mono);
      font-size: 13px;
      color: var(--ember);
      background: var(--surface);
      border: 1px solid var(--rail);
      border-radius: var(--radius);
      padding: 1px 6px;
      overflow-wrap: anywhere;
    }
    .notfound a { color: var(--ember); text-decoration: none; border-bottom: 1px solid var(--ember-line); }
    .notfound a:hover { border-bottom-color: var(--ember); }

    @media (max-width: 600px) {
      .shell { padding: 0 16px; }
      .bar-in { padding: 10px 16px; }
      .top { padding: 30px 0 20px; }
      .wordmark { font-size: 25px; }
      .readout { gap: 18px; }
      .notfound { padding: 60px 0 80px; }
    }
  CSS

  INDEX_JS = <<-JS
    (function () {
      var input = document.getElementById('search');
      if (!input) return;
      var totalEl = document.getElementById('stat-visible');
      var emptyEl = document.getElementById('empty');

      // Walk the DOM once at startup and cache each category with its own
      // rows plus their pre-lowercased haystack. The previous version called
      // querySelectorAll once per category on every keystroke, which is ~175
      // full subtree scans per character typed.
      //
      // `props` is padded with spaces on both sides so a chip can match a
      // whole token ('control') without also matching a longer token that
      // merely contains it ('non-xss-control').
      var groups = [].map.call(document.querySelectorAll('.cat'), function (cat) {
        var rows = [].map.call(cat.querySelectorAll('.maze'), function (el) {
          return {
            el: el,
            hay: el.getAttribute('data-hay') || '',
            props: ' ' + (el.getAttribute('data-p') || '') + ' '
          };
        });
        return { el: cat, rows: rows };
      });

      // Active chip tokens, kept as a flat array so the hot loop allocates
      // nothing per keystroke.
      var keys = [];

      function apply() {
        var q = input.value.toLowerCase().trim();
        var visible = 0;
        for (var i = 0; i < groups.length; i++) {
          var group = groups[i];
          var shown = 0;
          for (var j = 0; j < group.rows.length; j++) {
            var row = group.rows[j];
            var match = q === '' || row.hay.indexOf(q) !== -1;
            for (var k = 0; match && k < keys.length; k++) {
              if (row.props.indexOf(keys[k]) === -1) match = false;
            }
            row.el.classList.toggle('hidden', !match);
            if (match) shown++;
          }
          group.el.classList.toggle('hidden', shown === 0);
          visible += shown;
        }
        if (totalEl) totalEl.textContent = visible;
        if (emptyEl) emptyEl.classList.toggle('hidden', visible !== 0);
      }

      input.addEventListener('input', apply);

      [].forEach.call(document.querySelectorAll('.chip'), function (chip) {
        chip.addEventListener('click', function () {
          var on = chip.getAttribute('aria-pressed') !== 'true';
          chip.setAttribute('aria-pressed', on ? 'true' : 'false');
          var token = ' ' + chip.getAttribute('data-filter') + ' ';
          var at = keys.indexOf(token);
          if (on && at === -1) keys.push(token);
          if (!on && at !== -1) keys.splice(at, 1);
          apply();
        });
      });

      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input) {
          e.preventDefault();
          input.focus();
        } else if (e.key === 'Escape' && document.activeElement === input) {
          input.value = '';
          apply();
          input.blur();
        }
      });

      var toggle = document.getElementById('theme');
      if (toggle) {
        toggle.addEventListener('click', function () {
          var root = document.documentElement;
          var now = root.getAttribute('data-theme');
          if (!now) {
            now = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
          }
          var next = now === 'dark' ? 'light' : 'dark';
          root.setAttribute('data-theme', next);
          try { localStorage.setItem('xssmaze-theme', next); } catch (err) { /* private mode */ }
        });
      }

      // Re-apply on load so a value restored by the browser (back/forward,
      // autofill) is reflected instead of showing an unfiltered list.
      if (input.value) apply();
    })();
  JS

  # Runs before first paint so a stored theme choice does not flash the
  # system theme first. Kept tiny and inlined into <head> for that reason.
  THEME_BOOT_JS = "try{var t=localStorage.getItem('xssmaze-theme');" \
                  "if(t)document.documentElement.setAttribute('data-theme',t)}catch(e){}"

  # The brand mark: a square unicursal spiral, i.e. a maze reduced to one
  # unbroken corridor. Reused as the favicon, where `currentColor` cannot
  # help, so the two themes are resolved inside the file.
  FAVICON_SVG = <<-SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <style>
        path { stroke: #9f5518; }
        @media (prefers-color-scheme: dark) { path { stroke: #d9853b; } }
      </style>
      <path d="M12 12 L12 9 L15 9 L15 15 L9 15 L9 6 L18 6 L18 18 L6 18 L6 3 L21 3"
            fill="none" stroke-width="1.7" stroke-linecap="square" stroke-linejoin="miter"/>
    </svg>
    SVG

  # Inline copy of the same mark for the header. Styled by .mark in CSS so it
  # inherits the accent and the draw animation.
  MARK_SVG = "<svg class='mark' viewBox='0 0 24 24' aria-hidden='true'>" \
             "<path d='M12 12 L12 9 L15 9 L15 15 L9 15 L9 6 L18 6 L18 18 L6 18 L6 3 L21 3'/></svg>"
end
