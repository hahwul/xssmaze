# Real markdown-renderer XSS shapes. Modeled after issues from marked,
# markdown-it, showdown, remark and CMS renderers — these patterns
# keep recurring in bug-bounty reports against note apps, doc platforms,
# and AI chat front-ends.
#
# Each level pre-builds the markdown skeleton server-side and slots a
# single user-controlled field into it. That makes the case detectable
# by stock XSS scanners (a raw payload sent to the parameter lands
# directly in an href / src / attribute) while still preserving the
# CVE shape: the bug only triggers because the markdown renderer
# failed to filter that specific position.
# Level 1: javascript: scheme inside a markdown link
# CVE shape: marked CVE-2017-1000427, markdown-it #167 lineage.
# User supplies just the URL; server builds [text](url) and renders.
Xssmaze.push("markdown-level1", "/markdown/level1/?url=https://example.com", "markdown link href: no scheme check", "GET", ["url"])
maze_get "/markdown/level1/" do |env|
  url = env.params.query.fetch("url", "#")
  md = "[click here](#{url})"
  html = md.gsub(/\[([^\]]*)\]\(([^)\s]+)\)/) do
    "<a href=\"#{$2}\">#{$1}</a>"
  end

  "<!doctype html><html><body><article>#{html}</article></body></html>"
end

# Level 2: javascript: scheme inside a markdown image
# showdown <1.9, older marked. Server builds ![alt](src).
Xssmaze.push("markdown-level2", "/markdown/level2/?src=/img/cat.png", "markdown image src: no scheme check", "GET", ["src"])
maze_get "/markdown/level2/" do |env|
  src = env.params.query.fetch("src", "/img/default.png")
  md = "![profile photo](#{src})"
  html = md.gsub(/!\[([^\]]*)\]\(([^)\s]+)\)/) do
    "<img src=\"#{$2}\" alt=\"#{$1}\">"
  end

  "<!doctype html><html><body>#{html}</body></html>"
end

# Level 3: HTML pass-through (raw HTML allowed in markdown)
# markdown-it `html: true`, GitLab banzai, Discourse cooked output.
# Scanner detects directly — `<script>` survives the renderer.
Xssmaze.push("markdown-level3", "/markdown/level3/?query=hello", "markdown html:true pass-through (raw HTML survives)")
maze_get "/markdown/level3/" do |env|
  query = env.params.query["query"]
  html = query.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{$1}</strong>" }
    .gsub(/\*([^*]+)\*/) { "<em>#{$1}</em>" }
    .gsub(/\n/, "<br>")

  "<!doctype html><html><body><div class='markdown-body'>#{html}</div></body></html>"
end

# Level 4: autolink with no scheme whitelist
# Older markdown autolinkers accept any URI inside <...> and emit
# <a href="...">. CommonMark whitelists schemes; the buggy ones
# don't. Scanner gets the URL slot directly.
Xssmaze.push("markdown-level4", "/markdown/level4/?url=https://example.com", "markdown autolink with no scheme whitelist", "GET", ["url"])
maze_get "/markdown/level4/" do |env|
  url = env.params.query.fetch("url", "https://example.com")
  md = "<#{url}>"
  html = md.gsub(/<([a-z][a-z0-9+.-]*:[^>\s]+)>/i) do
    u = $1
    "<a href=\"#{u}\">#{u}</a>"
  end

  "<!doctype html><html><body>#{html}</body></html>"
end

# Level 5: reference-style link, attacker controls the [1]: URL
# Reference defs are resolved in a second pass; single-pass href
# filters miss them. Real shape: CMS where a user pastes a body
# containing `[label][1]` and the URL is collected separately.
Xssmaze.push("markdown-level5", "/markdown/level5/?ref_url=https://example.com", "markdown reference-style link url (deferred resolution)", "GET", ["ref_url"])
maze_get "/markdown/level5/" do |env|
  ref_url = env.params.query.fetch("ref_url", "https://example.com")
  md = "[click here][1]\n\n[1]: #{ref_url}"
  refs = {} of String => String
  md.scan(/^\s*\[([^\]]+)\]:\s*(\S+)\s*$/m) do |m|
    refs[m[1]] = m[2]
  end
  html = md.gsub(/\[([^\]]+)\]\[([^\]]+)\]/) do
    text = $1
    url = refs[$2]? || "#"
    "<a href=\"#{url}\">#{text}</a>"
  end
  html = html.gsub(/^\s*\[[^\]]+\]:\s*\S+\s*$/m, "")

  "<!doctype html><html><body><article>#{html}</article></body></html>"
end

# Level 6: image title attribute reflected unescaped
# Renderers that build `<img title="...">` from the markdown title
# field without escaping allow attribute-quote breakout. Scanner
# gets the title slot directly.
Xssmaze.push("markdown-level6", "/markdown/level6/?title=friendly+cat", "markdown image title attribute unescaped", "GET", ["title"])
maze_get "/markdown/level6/" do |env|
  title = env.params.query.fetch("title", "")
  md = %(![alt](/img/cat.png "#{title}"))
  html = md.gsub(/!\[([^\]]*)\]\(([^)\s]+)\s+"([^"]*)"\)/) do
    "<img src=\"#{$2}\" alt=\"#{$1}\" title=\"#{$3}\">"
  end

  "<!doctype html><html><body>#{html}</body></html>"
end
