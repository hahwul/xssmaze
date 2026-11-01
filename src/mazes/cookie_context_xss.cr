# Cookie-delivered reflection across the contexts a real app echoes a
# preference/session cookie into. The existing cookie coverage (header-level4,
# dom-level12) only echoes the raw Cookie header into the HTML body; these
# land a single named cookie value in an unquoted attribute, a bare JS
# expression, and a URL sink, plus one true-negative control.
#
# Every breakout here is reachable with cookie-safe bytes only. A raw double
# quote cannot survive cookie delivery (the cookie parser truncates the value
# at the first `"`), so a quoted-attribute or quoted-JS-string breakout is
# deliberately NOT used — those would be unsolvable through a cookie and would
# mislabel the corpus. Space, `=`, `(`, `)`, `<` and `>` all pass through, so
# the exploitable levels rely only on those. A scanner has to inject into the
# cookie (not the query) and then solve the context.

# Level 1: `theme` cookie reflected into an UNQUOTED attribute value.
# Bypass: x onmouseover=alert(1)   (space-separated handler, no quote needed)
Xssmaze.push("cookiectx-level1", "/cookiectx/level1/", "theme cookie in unquoted attribute value",
  "GET", ["theme"],
  vuln: "reflected-attr", delivery: ["cookie"],
  note: "the `theme` cookie value lands in an unquoted class attribute; add a space-separated event handler (no quote needed, and a cookie cannot carry a raw double quote)")
maze_get "/cookiectx/level1/" do |env|
  theme = env.request.cookies["theme"]?.try(&.value) || "light"
  "<html><body><div class=#{theme}>preferences</div></body></html>"
end

# Level 2: `uid` cookie reflected as a bare expression inside <script>.
# Bypass: alert(1)   (executes on load; parentheses survive cookie delivery)
Xssmaze.push("cookiectx-level2", "/cookiectx/level2/", "uid cookie as bare JS expression",
  "GET", ["uid"],
  vuln: "reflected-js", delivery: ["cookie"],
  note: "the `uid` cookie value is reflected raw as the right-hand side of an assignment in an inline <script>, so a bare expression like alert(1) runs on load without any string breakout")
maze_get "/cookiectx/level2/" do |env|
  uid = env.request.cookies["uid"]?.try(&.value) || "0"
  "<html><body><script>var uid = #{uid};</script></body></html>"
end

# Level 3: `next` cookie reflected into an <a href> URL sink.
# Bypass: javascript:alert(1)
Xssmaze.push("cookiectx-level3", "/cookiectx/level3/", "next cookie in anchor href URL sink",
  "GET", ["next"],
  vuln: "reflected-attr", delivery: ["cookie"],
  note: "the `next` cookie value is used verbatim as an <a href>; a javascript: URL executes on click, and the value is not scheme-filtered")
maze_get "/cookiectx/level3/" do |env|
  nxt = env.request.cookies["next"]?.try(&.value) || "/"
  "<html><body><a href=\"#{nxt}\">continue</a></body></html>"
end

# Level 4 (control): `lang` cookie HTML-escaped before it reaches the body.
# Correct result is no finding — the value can never introduce markup.
Xssmaze.push("cookiectx-level4", "/cookiectx/level4/", "lang cookie HTML-escaped in body (safe control)",
  "GET", ["lang"],
  vuln: "non-xss-control", delivery: ["cookie"], exploitable: false,
  note: "the `lang` cookie value is HTML-escaped before reflection, so no markup can form; reporting no XSS here is the correct result")
maze_get "/cookiectx/level4/" do |env|
  lang = env.request.cookies["lang"]?.try(&.value) || "en"
  "<html><body><p>Language: #{Xssmaze.html_escape(lang)}</p></body></html>"
end
