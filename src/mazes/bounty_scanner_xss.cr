# Real-world bug-bounty shapes that an ordinary XSS scanner can detect
# with its stock payload set — every level has a single user-controlled
# parameter that lands directly in an HTML context, so a raw
# `<script>alert(1)</script>` or `"><svg onload=...>` payload fires
# without requiring the scanner to know any framework-specific trick.
def load_bounty_scanner_xss
  # Level 1: Open Graph meta tag content reflection
  # CVE shape: news/blog/SaaS share-preview pages embed a tenant- or
  # query-controlled title into `<meta property="og:title" content="X">`.
  # Quote-context attribute injection — fires on `"><svg onload=...>`.
  Xssmaze.push("scanbounty-level1", "/scanbounty/level1/?title=Welcome", "Open Graph og:title meta content reflection", "GET", ["title"])
  maze_get "/scanbounty/level1/" do |env|
    title = env.params.query.fetch("title", "Welcome")

    "<!doctype html><html><head>
    <meta property=\"og:title\" content=\"#{title}\">
    <meta property=\"og:type\" content=\"website\">
    <title>#{title}</title>
    </head><body><h1>#{title}</h1></body></html>"
  end

  # Level 2: pagination param reflected in `<a href>`
  # `?page=2` lands back in `<a href="?page=2">Next</a>` and
  # `<link rel="next">`. Attribute-context — `"><script>` works.
  Xssmaze.push("scanbounty-level2", "/scanbounty/level2/?page=1", "pagination param reflected in next-page link href", "GET", ["page"])
  maze_get "/scanbounty/level2/" do |env|
    page = env.params.query.fetch("page", "1")

    "<!doctype html><html><head>
    <link rel=\"next\" href=\"?page=#{page}\">
    </head><body>
    <p>Page #{page} of results</p>
    <a href=\"?page=#{page}\">Current</a>
    </body></html>"
  end

  # Level 3: `<html lang="X">` attribute breakout via locale switcher
  # `/app?lang=en` apps reflect the locale code into the root `<html
  # lang>` attribute. Attribute breakout with `"><script>` — directly
  # observed in CMS / e-commerce templates.
  Xssmaze.push("scanbounty-level3", "/scanbounty/level3/?lang=en", "<html lang> attribute breakout via locale param", "GET", ["lang"])
  maze_get "/scanbounty/level3/" do |env|
    lang = env.params.query.fetch("lang", "en")

    "<!doctype html><html lang=\"#{lang}\"><head>
    <meta charset='utf-8'>
    </head><body>
    <p>Current locale: #{lang}</p>
    </body></html>"
  end

  # Level 4: JSON-LD structured data name field
  # Many e-commerce / news sites build `<script
  # type="application/ld+json">{...}</script>` with the product / article
  # name pulled from the request. JS-string context inside <script>;
  # `</script><script>alert(1)</script>` closes the block.
  Xssmaze.push("scanbounty-level4", "/scanbounty/level4/?name=Sample", "JSON-LD structured data name field reflection", "GET", ["name"])
  maze_get "/scanbounty/level4/" do |env|
    name = env.params.query.fetch("name", "Sample Product")

    "<!doctype html><html><head>
    <script type=\"application/ld+json\">
    {\"@context\":\"https://schema.org\",\"@type\":\"Product\",\"name\":\"#{name}\"}
    </script>
    </head><body><h1>#{name}</h1></body></html>"
  end

  # Level 5: `?return_to=` parameter reflected as login form action
  # Login / logout / signup pages echo the post-auth destination into
  # the form's `action` attribute and into a "Cancel" link. Attribute
  # breakout — fires on `" autofocus onfocus=alert(1) x="`.
  Xssmaze.push("scanbounty-level5", "/scanbounty/level5/?return_to=/dashboard", "return_to param reflected in form action + cancel link", "GET", ["return_to"])
  maze_get "/scanbounty/level5/" do |env|
    rt = env.params.query.fetch("return_to", "/")

    "<!doctype html><html><body>
    <form method='post' action=\"/login?return_to=#{rt}\">
      <input type='email' name='email'>
      <button type='submit'>Sign in</button>
    </form>
    <a href=\"#{rt}\">Cancel</a>
    </body></html>"
  end

  # Level 6: `<iframe src>` built from `?embed=` parameter
  # Doc / widget hosts allow embedding via `?embed=URL`. Server slots
  # the URL straight into `<iframe src>`. Detect via `javascript:`
  # scheme or `"><svg onload=...>` quote breakout.
  Xssmaze.push("scanbounty-level6", "/scanbounty/level6/?embed=https://example.com", "iframe src from embed= param (scheme + attr breakout)", "GET", ["embed"])
  maze_get "/scanbounty/level6/" do |env|
    embed = env.params.query.fetch("embed", "about:blank")

    "<!doctype html><html><body>
    <h1>Embedded content</h1>
    <iframe src=\"#{embed}\" width='640' height='480'></iframe>
    </body></html>"
  end

  # Level 7: `?tag=` reflected in tracking pixel src
  # Analytics / marketing tag-manager templates build
  # `<img src="https://t.example/p?tag=X">` from the visitor's tag
  # parameter. Image src is a forgiving attribute context — fires on
  # `"><svg onload=...>` and `onerror` payloads.
  Xssmaze.push("scanbounty-level7", "/scanbounty/level7/?tag=newsletter", "tracking pixel src tag reflection", "GET", ["tag"])
  maze_get "/scanbounty/level7/" do |env|
    tag = env.params.query.fetch("tag", "default")

    "<!doctype html><html><body>
    <p>Thanks for visiting.</p>
    <img src=\"/pixel?tag=#{tag}\" width='1' height='1' alt=''>
    </body></html>"
  end

  # Level 8: theme color reflected into inline `<style>` block
  # CMS themes accept `?color=` and emit `body { background: COLOR; }`
  # into a `<style>` tag. CSS context — closes with `;}</style>
  # <script>...`. Standard CSS-injection / CSS-context scanner payload.
  Xssmaze.push("scanbounty-level8", "/scanbounty/level8/?color=blue", "theme color reflected into inline <style>", "GET", ["color"])
  maze_get "/scanbounty/level8/" do |env|
    color = env.params.query.fetch("color", "white")

    "<!doctype html><html><head>
    <style>body { background: #{color}; color: #333; }</style>
    </head><body>
    <h1>Welcome</h1>
    </body></html>"
  end
end
