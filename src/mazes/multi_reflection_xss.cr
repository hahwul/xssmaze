require "json"

# Multi-reflection: one parameter lands in several distinct contexts on
# the same page. Scanners that pick a single payload per parameter often
# only flag one location and miss the rest; context-aware scanners
# should detect every reflection and choose the right payload for each.
#
# Every level uses one input and reflects it into 3+ contexts. At least
# one of those contexts is reachable with a stock payload, so basic
# scanners still register a hit — these cases exist to grade how well a
# scanner enumerates *all* reflections.
def load_multi_reflection_xss
  # Level 1: search query reflected 4 times, all raw
  # Contexts: <title>, <h1>, <input value=>, <meta og:title content=>.
  # Real shape: every SaaS search results page.
  Xssmaze.push("multireflect-level1", "/multireflect/level1/?q=widget", "1 param × 4 raw contexts (title/h1/input/meta)", "GET", ["q"])
  maze_get "/multireflect/level1/" do |env|
    q = env.params.query.fetch("q", "")

    "<!doctype html><html><head>
    <title>Search: #{q}</title>
    <meta property=\"og:title\" content=\"Search: #{q}\">
    </head><body>
    <h1>Results for #{q}</h1>
    <form><input name='q' value=\"#{q}\"></form>
    </body></html>"
  end

  # Level 2: 4 contexts, 3 escaped, only 1 unsafe
  # Real shape: dev escaped most spots but forgot the `<meta>` content.
  # The "missed one" CVE pattern — scanner must enumerate all
  # reflections to find the unsafe one.
  Xssmaze.push("multireflect-level2", "/multireflect/level2/?q=widget", "4 contexts, only <meta> content is unsafe", "GET", ["q"])
  maze_get "/multireflect/level2/" do |env|
    q = env.params.query.fetch("q", "")
    safe = Xssmaze.html_escape(q)

    "<!doctype html><html><head>
    <title>Search: #{safe}</title>
    <meta property=\"og:description\" content=\"Looking for #{q}\">
    </head><body>
    <h1>Results for #{safe}</h1>
    <form><input name='q' value=\"#{safe}\"></form>
    </body></html>"
  end

  # Level 3: same input in HTML body + JS string literal
  # Contexts need different payloads: body wants `<script>`,
  # JS-string wants `'-alert(1)-'`. Single-payload scanners typically
  # miss one half.
  Xssmaze.push("multireflect-level3", "/multireflect/level3/?name=guest", "body context + JS string literal", "GET", ["name"])
  maze_get "/multireflect/level3/" do |env|
    name = env.params.query.fetch("name", "guest")

    "<!doctype html><html><body>
    <h1>Hello, #{name}!</h1>
    <script>var currentUser = '#{name}'; console.log(currentUser);</script>
    </body></html>"
  end

  # Level 4: same input in href + src + body + JSON-LD
  # 4 distinct contexts each requiring its own payload shape.
  # Real shape: product page reflecting product name across multiple
  # SEO/metadata spots.
  Xssmaze.push("multireflect-level4", "/multireflect/level4/?slug=demo", "href + src + body + JSON-LD multi-context", "GET", ["slug"])
  maze_get "/multireflect/level4/" do |env|
    slug = env.params.query.fetch("slug", "demo")

    "<!doctype html><html><head>
    <link rel=\"canonical\" href=\"/p/#{slug}\">
    <script type=\"application/ld+json\">
    {\"@type\":\"Product\",\"name\":\"#{slug}\"}
    </script>
    </head><body>
    <img src=\"/img/#{slug}.png\" alt='product'>
    <h1>#{slug}</h1>
    </body></html>"
  end

  # Level 5: comment context + attribute + body
  # HTML comment `<!-- ... -->` allows breakout with `-->`. Attribute
  # uses single quotes. Body is raw. Three distinct exploit paths.
  Xssmaze.push("multireflect-level5", "/multireflect/level5/?tag=ok", "HTML comment + single-quote attr + body", "GET", ["tag"])
  maze_get "/multireflect/level5/" do |env|
    tag = env.params.query.fetch("tag", "ok")

    "<!doctype html><html><body>
    <!-- last-tag: #{tag} -->
    <div class='tag-#{tag}'>tag wrapper</div>
    <p>You picked: #{tag}</p>
    </body></html>"
  end

  # Level 6: JSON-encoded in script + raw in body
  # JSON.stringify-equivalent encoding is applied for the script
  # context (escapes quotes and backslashes), but the body reflects
  # raw. Scanners that only test JSON-string-context payloads will
  # miss the body; scanners that only test body context will miss
  # the JSON path's JSON-aware escapes.
  Xssmaze.push("multireflect-level6", "/multireflect/level6/?msg=hi", "JSON-encoded script + raw body", "GET", ["msg"])
  maze_get "/multireflect/level6/" do |env|
    msg = env.params.query.fetch("msg", "hi")
    json_safe = msg.to_json # produces "..." with internal escapes

    "<!doctype html><html><body>
    <p>#{msg}</p>
    <script>window.__msg = #{json_safe};</script>
    </body></html>"
  end

  # Level 7: name + email reflected, only email is exploitable
  # Two different param names land in similar-looking spots. Scanner
  # must exercise each parameter and find that only `email` is unsafe
  # (name is escaped). Common in signup confirmation pages.
  Xssmaze.push("multireflect-level7", "/multireflect/level7/?name=Anna&email=a@b.c", "name escaped, email reflected raw", "GET", ["name", "email"])
  maze_get "/multireflect/level7/" do |env|
    name = Xssmaze.html_escape(env.params.query.fetch("name", ""))
    email = env.params.query.fetch("email", "")

    "<!doctype html><html><body>
    <p>Welcome, #{name}!</p>
    <p>We sent a confirmation to <em>#{email}</em>.</p>
    </body></html>"
  end

  # Level 8: same value reflected differently per Accept header path
  # HTML response: raw reflection. JSON response (Accept: application/json):
  # JSON-encoded. Real shape: APIs that serve dual content-types from
  # one endpoint, and only one of the response paths is XSS-safe.
  Xssmaze.push("multireflect-level8", "/multireflect/level8/?value=ok", "dual content-type response (HTML raw / JSON safe)", "GET", ["value"])
  maze_get "/multireflect/level8/" do |env|
    value = env.params.query.fetch("value", "ok")
    accept = env.request.headers.fetch("Accept", "text/html")

    if accept.includes?("application/json")
      env.response.content_type = "application/json"
      {value: value}.to_json
    else
      "<!doctype html><html><body><div>value: #{value}</div></body></html>"
    end
  end
end
