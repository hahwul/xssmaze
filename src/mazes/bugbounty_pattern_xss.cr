# Patterns observed repeatedly in public bug-bounty reports and CVEs.
# Each level mirrors a concrete real-world sink rather than a synthetic
# context, so payload detectors can be calibrated against shapes that
# actually appear in production code (OAuth flows, JWT dashboards,
# upload previews, third-party widget snippets, etc.).
def load_bugbounty_pattern_xss
  # Level 1: OAuth redirect_uri reflected in the login error template
  # Mirrors CVE-2020-12625 / countless reports against IdP login pages
  # that echo the raw `redirect_uri` into a "Continue to ..." link or
  # a hidden form. The attribute is single-quoted and unencoded.
  Xssmaze.push("bugbounty-level1", "/bugbounty/level1/?redirect_uri=https://app.example.com/cb", "OAuth redirect_uri reflected in login form action", "GET", ["redirect_uri"])
  maze_get "/bugbounty/level1/" do |env|
    redirect_uri = env.params.query.fetch("redirect_uri", "/")

    "<!doctype html><html><body>
    <h1>Sign in</h1>
    <p>Continue to <a href='#{redirect_uri}'>application</a></p>
    <form method='post' action='/oauth/authorize'>
      <input type='hidden' name='redirect_uri' value='#{redirect_uri}'>
      <input type='email' name='email'>
      <button type='submit'>Continue</button>
    </form>
    </body></html>"
  end

  # Level 2: OAuth `error_description` reflected on callback
  # Auth0, Okta, and several SSO providers historically reflected the
  # raw `error_description` query param into the error page. Bug bounty
  # reports against these flows are still common — see HackerOne reports
  # under the OAuth/SSO tag.
  Xssmaze.push("bugbounty-level2", "/bugbounty/level2/?error=invalid_request&error_description=bad+input", "OAuth error_description reflected on callback", "GET", ["error_description"])
  maze_get "/bugbounty/level2/" do |env|
    err = env.params.query.fetch("error", "unknown_error")
    desc = env.params.query.fetch("error_description", "")

    "<!doctype html><html><body>
    <div class='oauth-error'>
      <h2>Authentication failed</h2>
      <p><strong>#{err}:</strong> #{desc}</p>
      <a href='/'>Return to homepage</a>
    </div>
    </body></html>"
  end

  # Level 3: search query reflected into <title> tag
  # CVE shape: dozens of CMS and SaaS apps (search results pages) put
  # the user's query into the page title without escaping. Quick wins
  # for any scanner: `</title><script>alert(1)</script>` breaks out and
  # executes. Direct reflection, no chain required.
  Xssmaze.push("bugbounty-level3", "/bugbounty/level3/?q=widget", "search query reflected into <title>", "GET", ["q"])
  maze_get "/bugbounty/level3/" do |env|
    q = env.params.query.fetch("q", "")

    "<!doctype html><html><head>
    <title>Search results for #{q} - MyApp</title>
    </head><body>
    <h1>Results</h1>
    <p>No products matched.</p>
    </body></html>"
  end

  # Level 4: Password-reset token reflected as hidden input value
  # The token comes from an email link and lands in a form. Apps that
  # build the form server-side with naive string concat allow attribute
  # breakout — historically observed in WordPress plugins, Laravel
  # apps, and several Drupal modules.
  Xssmaze.push("bugbounty-level4", "/bugbounty/level4/?token=abc123", "password reset token in hidden input (attribute breakout)", "GET", ["token"])
  maze_get "/bugbounty/level4/" do |env|
    token = env.params.query.fetch("token", "")

    "<!doctype html><html><body>
    <h1>Reset your password</h1>
    <form method='post' action='/account/reset'>
      <input type=\"hidden\" name=\"token\" value=\"#{token}\">
      <label>New password <input type='password' name='password'></label>
      <button type='submit'>Reset</button>
    </form>
    </body></html>"
  end

  # Level 5: Uploaded filename echoed into <img alt> and preview caption
  # Image gallery / CMS upload flows often display the uploaded file
  # name back to the user. The filename arrives from the multipart
  # `filename` parameter (Content-Disposition) — attacker-controlled.
  # Both attribute and body contexts are exploitable.
  Xssmaze.push("bugbounty-level5", "/bugbounty/level5/?filename=cat.png", "upload filename reflected in img alt + caption", "GET", ["filename"])
  maze_get "/bugbounty/level5/" do |env|
    filename = env.params.query.fetch("filename", "image.png")

    "<!doctype html><html><body>
    <h1>Upload complete</h1>
    <figure>
      <img src='/uploads/preview.png' alt='#{filename}'>
      <figcaption>You uploaded: #{filename}</figcaption>
    </figure>
    </body></html>"
  end

  # Level 6: 3rd-party widget snippet with reflected data-shortname
  # Disqus / Intercom / Tawk.to embed snippets are frequently rendered
  # server-side with a tenant-controlled shortname/site_id. Apps that
  # let a user pick this value via querystring (admin preview, multi-
  # tenant dashboards) leak the attribute context into an inline script
  # block.
  Xssmaze.push("bugbounty-level6", "/bugbounty/level6/?shortname=test", "third-party embed snippet with reflected data attr", "GET", ["shortname"])
  maze_get "/bugbounty/level6/" do |env|
    shortname = env.params.query.fetch("shortname", "demo")

    "<!doctype html><html><body>
    <div id='comments'></div>
    <script>
      var disqus_config = function () {
        this.page.identifier = '#{shortname}';
      };
      (function() {
        var d = document, s = d.createElement('script');
        s.src = 'https://#{shortname}.disqus.com/embed.js';
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
      })();
    </script>
    </body></html>"
  end

  # Level 7: X-Forwarded-Host reflected into <base href> (cache poisoning)
  # Classic web-cache-poisoning + XSS chain. The CDN keys on path only;
  # an attacker injects via X-Forwarded-Host and the resulting <base>
  # rewrites every subsequent relative resource. Documented by James
  # Kettle's PortSwigger research and replicated in many bounty reports.
  Xssmaze.push("bugbounty-level7", "/bugbounty/level7/", "X-Forwarded-Host reflected in <base href> (cache poison chain)", "GET", ["X-Forwarded-Host"])
  maze_get "/bugbounty/level7/" do |env|
    host = env.request.headers.fetch("X-Forwarded-Host", env.request.headers.fetch("Host", "localhost"))

    "<!doctype html><html><head>
    <base href=\"https://#{host}/\">
    <title>Account</title>
    </head><body>
    <h1>Your account</h1>
    <link rel='canonical' href='https://#{host}/account'>
    </body></html>"
  end

  # Level 8: Git ref / branch name reflected in breadcrumb
  # GitLab, Gitea, and self-hosted Git UIs have repeatedly shipped XSS
  # via branch / tag / ref parameters (CVE-2021-22214 lineage). The ref
  # lands in a breadcrumb link plus a header.
  Xssmaze.push("bugbounty-level8", "/bugbounty/level8/?ref=main", "git ref/branch name reflected in breadcrumb + header", "GET", ["ref"])
  maze_get "/bugbounty/level8/" do |env|
    ref = env.params.query.fetch("ref", "main")

    "<!doctype html><html><body>
    <nav class='breadcrumb'>
      <a href='/repo'>repo</a> / <a href='/repo/tree/#{ref}'>#{ref}</a>
    </nav>
    <h2>Files in branch: #{ref}</h2>
    </body></html>"
  end

  # Level 9: API validation error reflecting the offending input
  # Pattern: backend rejects a malformed email/username and renders the
  # bad value back in the form. Quote-only escaping is applied, but
  # angle brackets pass through — exactly the regression seen in many
  # SaaS signup pages.
  Xssmaze.push("bugbounty-level9", "/bugbounty/level9/?email=bad", "validation error reflecting bad input (angle brackets unfiltered)", "GET", ["email"])
  maze_get "/bugbounty/level9/" do |env|
    email = Filters.escape_quotes(env.params.query.fetch("email", ""))

    "<!doctype html><html><body>
    <div class='alert alert-error'>
      <strong>Invalid email address:</strong> #{email}
    </div>
    <form method='post'>
      <input name='email' value=\"#{email}\">
      <button>Try again</button>
    </form>
    </body></html>"
  end

  # Level 10: Content sniffing on .json endpoint with HTML body
  # Variant on the classic "no X-Content-Type-Options" pattern. The
  # endpoint sets content-type to application/json but the response is
  # HTML-flavoured and browsers sniff it when navigated to directly.
  # Several CVEs against image/file servers match this shape.
  Xssmaze.push("bugbounty-level10", "/bugbounty/level10/?msg=hi", "JSON endpoint sniffable as HTML (no nosniff)", "GET", ["msg"])
  maze_get "/bugbounty/level10/" do |env|
    msg = env.params.query.fetch("msg", "")
    env.response.content_type = "application/json"
    # Intentionally NOT setting X-Content-Type-Options: nosniff.
    # Body is HTML-shaped; legacy sniffers and a few embed paths still
    # treat it as text/html when fetched without an Accept header.
    "<!doctype html><html><body><h1>#{msg}</h1></body></html>"
  end
end
