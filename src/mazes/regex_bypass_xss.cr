# Regex / WAF bypass shapes seen in actual CVEs and bounty reports.
# Each filter is the *real* filter — the bypass that the scanner needs
# to produce is short and well-known: case folding, slash separator,
# HTML entity inside an href value, single-pass nested strip,
# decode-after-filter, and a tag-whitelist that forgot a sink.
def load_regex_bypass_xss
  # Level 1: Case-sensitive `<script` strip (no /i flag)
  # Real shape: hand-rolled WAF rule, in-house template filter, or a
  # CMS plugin that forgot the case-insensitive flag. Bypass: `<Script>`
  # or any mixed case.
  Xssmaze.push("regexbypass-level1", "/regexbypass/level1/?query=a", "case-sensitive <script blacklist (no /i)")
  maze_get "/regexbypass/level1/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("<script", "").gsub("</script", "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 2: `\bon\w+\s*=` event-handler regex without slash handling
  # Real shape: regex requires alphanumeric tag/attr separator, but
  # HTML permits `/` between attributes. Bypass: `<svg/onload=alert(1)>`
  # or `<img/src=x/onerror=alert(1)>`. Documented in many WAF bypass
  # write-ups.
  Xssmaze.push("regexbypass-level2", "/regexbypass/level2/?query=a", "on*= regex requires whitespace prefix (slash bypass)")
  maze_get "/regexbypass/level2/" do |env|
    query = env.params.query["query"]
    # Filter requires literal whitespace before the event handler, so
    # `<svg/onload=...>` and `<img/src=x/onerror=...>` pass through.
    filtered = query.gsub(/\s+on\w+\s*=/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 3: `javascript:` literal strip in href, but browser decodes entities
  # Real shape: server-side filter scans the literal text for
  # `javascript:` and rejects, but the value is reflected into an
  # `href=` attribute where browsers decode HTML entities before URL
  # parsing. Bypass: `javas&#99;ript:alert(1)` or `&#106;avascript:`.
  # The lab also strips `data:` to keep the channel narrow.
  Xssmaze.push("regexbypass-level3", "/regexbypass/level3/?query=https://example.com", "javascript: literal strip but href decodes entities")
  maze_get "/regexbypass/level3/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/javascript:/i, "").gsub(/data:/i, "")

    "<html><body><a href=\"#{filtered}\">Continue</a></body></html>"
  end

  # Level 4: Single-pass keyword strip — nesting bypass
  # Real shape: `gsub("<script>", "")` is run once. `<scr<script>ipt>`
  # collapses to `<script>` after the strip. Classic CVE pattern
  # (countless CMS plugin advisories).
  Xssmaze.push("regexbypass-level4", "/regexbypass/level4/?query=a", "single-pass <script> strip (nested-tag bypass)")
  maze_get "/regexbypass/level4/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/<script>/i, "").gsub(/<\/script>/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 5: Filter operates on encoded input, sink decodes
  # Real shape: server HTML-escapes `<` and `>`, then the value is
  # decoded by client-side JS (decodeURIComponent + innerHTML) on
  # render. Bypass: send `%3Cscript%3E...%3C/script%3E` URL-encoded
  # past the server filter; the JS sink decodes and parses it.
  # Pattern observed in many SPA error pages.
  Xssmaze.push("regexbypass-level5", "/regexbypass/level5/?query=a", "server encodes < and >, client JS decodes via innerHTML")
  maze_get "/regexbypass/level5/" do |env|
    query = env.params.query["query"]
    filtered = Filters.encode_angles(query)

    "<html><body>
    <div id='out'></div>
    <script>
      var raw = '#{filtered}';
      document.getElementById('out').innerHTML = decodeURIComponent(raw);
    </script>
    </body></html>"
  end

  # Level 6: Tag whitelist forgets a script-equivalent sink
  # Real shape: blacklist covers `script|img|iframe|svg|object|embed`
  # but the lab page renders user input inside an environment where
  # `<details ontoggle>`, `<input autofocus onfocus>`, or
  # `<video src=x onerror>` still execute. Standard scanner payload
  # rotation finds it.
  Xssmaze.push("regexbypass-level6", "/regexbypass/level6/?query=a", "blacklist misses details/input/video sinks")
  maze_get "/regexbypass/level6/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub(/<\/?(script|img|iframe|svg|object|embed)[^>]*>/i, "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 7: Newline-stripping but tab/CR allowed
  # Real shape: filter strips `\n` to defeat header-injection-style
  # attacks, but `\t` and `\r` still pass and HTML treats them as
  # whitespace. Bypass: `<img\tsrc=x\tonerror=alert(1)>`.
  Xssmaze.push("regexbypass-level7", "/regexbypass/level7/?query=a", "newline strip with tab/CR untouched")
  maze_get "/regexbypass/level7/" do |env|
    query = env.params.query["query"]
    filtered = query.gsub("\n", "")

    "<html><body>#{filtered}</body></html>"
  end

  # Level 8: Signature filter targets `alert(` literal
  # Real shape: filter rejects the literal `alert(` substring assuming
  # all PoCs use it. Bypass: `(alert)(1)`, ``alert`1` ``, `top['ale'+'rt'](1)`,
  # `confirm(1)`, `prompt(1)` — any equivalent sink. Reflective into
  # a JS string context inside `<script>`.
  Xssmaze.push("regexbypass-level8", "/regexbypass/level8/?query=ok", "alert( literal signature inside JS sink")
  maze_get "/regexbypass/level8/" do |env|
    query = env.params.query["query"].gsub("alert(", "_blocked_")

    "<html><body>
    <script>var msg = \"#{query}\"; document.title = msg;</script>
    </body></html>"
  end
end
