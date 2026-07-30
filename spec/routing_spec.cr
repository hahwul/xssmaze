require "./spec_helper"

describe "Kemal routing integration" do
  it "serves basic level1 and reflects raw query" do
    payload = "<script>alert(1)</script>"
    get "/basic/level1/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(payload)
  end

  it "serves basic level2 and reflects escaped query" do
    payload = %(a"b)
    get "/basic/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(Filters.escape_double_quote(payload))
  end

  it "serves advanced level1 and reflects filtered query" do
    payload = "<script>alert(1)</script>"
    get "/advanced/level1/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(payload.gsub("script", ""))
  end

  it "serves modern-bypass level2 and reflects sanitized query" do
    payload = "<img onerror=alert(1)>"
    get "/modern-bypass/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("data-blocked-event=")
  end

  it "blocks modern-bypass level7 dangerous keywords with 403" do
    payload = "<script>alert(1)</script>"
    get "/modern-bypass/level7/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 403
    response.body.should contain("WAF Blocked")
  end

  it "dynamically configures security headers via query param overrides" do
    get "/basic/level1/?query=a&set_csp=default-src%20%27self%27&set_xcto=nosniff&set_xfo=deny"
    response.status_code.should eq 200
    response.headers["Content-Security-Policy"]?.should eq("default-src 'self'")
    response.headers["X-Content-Type-Options"]?.should eq("nosniff")
    response.headers["X-Frame-Options"]?.should eq("DENY")
  end

  it "implements XS-Leaks size oracle distinguishing admin from guest" do
    get "/xsleak/search?q=admin"
    admin_size = response.body.size

    get "/xsleak/search?q=guest"
    guest_size = response.body.size

    (admin_size > guest_size).should be_true
  end

  it "implements XS-Leaks load/error oracle where admin is 200 image/gif and guest is 404" do
    get "/xsleak/avatar.gif?q=admin"
    response.status_code.should eq 200
    response.headers["Content-Type"]?.should eq("image/gif")

    get "/xsleak/avatar.gif?q=guest"
    response.status_code.should eq 404
  end

  it "serves headless generator levels and handles POST parameters" do
    payload = "<h1>PDF Document Test</h1>"
    headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"}
    post "/headless-generator/level1/", headers: headers, body: "html=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("PDF Document Test")
  end

  it "serves HTML5 sanitizer level2 and preserves MathML and XMP namespaces" do
    payload = "<math><xmp><iframe srcdoc='<img src=x onerror=alert(1)>'></xmp></math>"
    get "/html5-sanitizer/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("<math><xmp>")
  end

  it "serves import map level1 and reflects dynamic modules" do
    payload = "data:text/javascript,alert(1)"
    get "/import-map/level1/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(%("whitelisted-module": "data:text/javascript,alert(1)"))
  end

  it "serves modern-bypass level19 postMessage portal" do
    get "/modern-bypass/level19/"
    response.status_code.should eq 200
    response.body.downcase.should contain("handshake")
  end

  it "blocks modern-bypass level20 first-level tag reflection via WAF" do
    get "/modern-bypass/level20/?query=%3Cscript%3E"
    response.status_code.should eq 403
    response.body.should contain("WAF Blocked")
  end

  it "serves modern-bypass level21 and serializes config raw inside script block" do
    payload = "guest"
    get "/modern-bypass/level21/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(%("username":"guest"))
  end

  it "serves modern-bypass level22 and reflects escaped Alpine attributes" do
    payload = "x-init=alert(1)"
    get "/modern-bypass/level22/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("x-init=alert(1)")
  end

  it "serves modern-bypass level23 and reflects query before the CSP meta tag" do
    payload = "<script>alert(1)</script>"
    get "/modern-bypass/level23/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("#{payload}\n  <meta http-equiv='Content-Security-Policy'")
  end

  it "serves modern-bypass level24 and evaluates CSTI in AngularJS container" do
    payload = "{{constructor.constructor('alert(1)')()}}"
    get "/modern-bypass/level24/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("Search keyword: #{payload}")
  end

  it "serves modern-bypass level25 and reflects inside JS template literals" do
    payload = "${alert(1)}"
    get "/modern-bypass/level25/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var message = `User workspace initialized: #{payload}`;")
  end

  it "serves modern-bypass level26 and loads nesting parameters" do
    get "/modern-bypass/level26/?config[__proto__][scriptUrl]=data:text/javascript,alert(1)"
    response.status_code.should eq 200
    response.body.should contain("Configuration Loader")
  end

  it "serves jquery level2 and reflects query into a $.parseHTML sink" do
    payload = "<img src=x onerror=alert(1)>"
    get "/jquery/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var raw = '#{payload}';")
    response.body.should contain("$.parseHTML(raw)")
  end

  it "serves jquery level4 and reflects a javascript: URL into .attr('href')" do
    payload = "javascript:alert(1)"
    get "/jquery/level4/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(".attr('href', '#{payload}')")
  end

  it "serves jquery level1 as a static page with a location.hash selector sink" do
    get "/jquery/level1/"
    response.status_code.should eq 200
    response.body.should contain("location.hash.slice(1)")
    response.body.should contain("$(target).appendTo")
  end

  it "serves codeexec level2 and reflects the specifier into a dynamic import()" do
    payload = "data:text/javascript,alert(1)"
    get "/codeexec/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("import('#{payload}')")
  end

  it "serves codeexec level4 and reflects the snippet into an inline script body" do
    payload = "alert(1)"
    get "/codeexec/level4/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var snippet = '#{payload}';")
    response.body.should contain("s.text = snippet;")
  end

  it "serves codeexec level6 and reflects the value into a dynamic script src" do
    payload = "//attacker.example/x.js"
    get "/codeexec/level6/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var src = '#{payload}';")
  end

  it "serves clientstate level1 with a localStorage seed-and-read innerHTML sink" do
    get "/clientstate/level1/?pref=a"
    response.status_code.should eq 200
    response.body.should contain("localStorage.setItem('pref', pref)")
    response.body.should contain("innerHTML = localStorage.getItem('pref')")
  end

  it "serves clientstate level5 with a history.state innerHTML sink" do
    get "/clientstate/level5/?note=a"
    response.status_code.should eq 200
    response.body.should contain("history.replaceState({ note: note }")
    response.body.should contain("innerHTML = st.note")
  end

  it "serves apidom level1 page that fetches its echo API into innerHTML" do
    get "/apidom/level1/?q=a"
    response.status_code.should eq 200
    response.body.should contain("fetch('/apidom/level1/api?q='")
    response.body.should contain("innerHTML = t")
  end

  it "echoes the q param raw from the apidom level1 API as text/plain" do
    payload = "<img src=x onerror=alert(1)>"
    get "/apidom/level1/api?q=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    (response.headers["Content-Type"]? || "").should contain("text/plain")
    response.body.should contain(payload)
  end

  it "echoes the q param raw inside JSON from the apidom level2 API" do
    payload = "<img src=x onerror=alert(1)>"
    get "/apidom/level2/api?q=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    (response.headers["Content-Type"]? || "").should contain("application/json")
    response.body.should contain(%({"html":"#{payload}"}))
  end

  it "serves htmlunsafe level1 as a static page with a setHTMLUnsafe(location.hash) sink" do
    get "/htmlunsafe/level1/"
    response.status_code.should eq 200
    response.body.should contain("location.hash.slice(1)")
    response.body.should contain(".setHTMLUnsafe(html)")
  end

  it "serves htmlunsafe level3 and reflects the query into a setHTMLUnsafe() string" do
    payload = "<img src=x onerror=alert(1)>"
    get "/htmlunsafe/level3/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var msg = '#{payload}';")
    response.body.should contain(".setHTMLUnsafe(msg)")
  end

  it "serves htmlunsafe level6 page that parses its fetch response via parseHTMLUnsafe" do
    get "/htmlunsafe/level6/?query=a"
    response.status_code.should eq 200
    response.body.should contain("fetch('/htmlunsafe/level6/api?query='")
    response.body.should contain("Document.parseHTMLUnsafe(t)")
  end

  it "echoes the query param raw from the htmlunsafe level6 API as text/html" do
    payload = "<img src=x onerror=alert(1)>"
    get "/htmlunsafe/level6/api?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    (response.headers["Content-Type"]? || "").should contain("text/html")
    response.body.should contain(payload)
  end

  it "serves dom level36 with an iframe srcdoc property sink from location.hash" do
    get "/dom/level36/"
    response.status_code.should eq 200
    response.body.should contain(".srcdoc = decodeURIComponent(location.hash.substring(1))")
  end

  it "serves dom level38 with an iframe srcdoc setAttribute sink from the query param" do
    get "/dom/level38/"
    response.status_code.should eq 200
    response.body.should contain(".setAttribute('srcdoc', query)")
  end

  it "serves navsink level1 as a static page with a window.open(location.hash) sink" do
    get "/navsink/level1/"
    response.status_code.should eq 200
    response.body.should contain("location.hash.slice(1)")
    response.body.should contain("window.open(target)")
  end

  it "serves navsink level3 with a location.assign(location.search) sink" do
    get "/navsink/level3/?query=a"
    response.status_code.should eq 200
    response.body.should contain("location.assign(next)")
  end

  it "serves navsink level5 and reflects the query into a window.open() string" do
    payload = "javascript:alert(1)"
    get "/navsink/level5/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var url = '#{payload}';")
    response.body.should contain("window.open(url)")
  end

  it "serves navsink level6 and reflects the query into a location.assign() string" do
    payload = "javascript:alert(1)"
    get "/navsink/level6/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var dest = '#{payload}';")
    response.body.should contain("location.assign(dest)")
  end

  it "serves domsource level1 with an IndexedDB read into innerHTML" do
    get "/domsource/level1/?query=a"
    response.status_code.should eq 200
    response.body.should contain("indexedDB.open('xssmaze-domsource'")
    response.body.should contain("innerHTML = ev.target.result")
  end

  it "serves domsource level2 parsing the fragment as its own querystring" do
    get "/domsource/level2/"
    response.status_code.should eq 200
    response.body.should contain("new URLSearchParams(location.hash.slice(1))")
  end

  it "serves domsource level3 with a popstate state round-trip" do
    get "/domsource/level3/?query=a"
    response.status_code.should eq 200
    response.body.should contain("addEventListener('popstate'")
    response.body.should contain("history.back()")
  end

  it "url-encodes the domsource level4 payload into the boot script src" do
    payload = "<img src=x onerror=alert(1)>"
    get "/domsource/level4/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("/domsource/level4/boot.js?msg=#{URI.encode_www_form(payload)}")
  end

  it "serves the domsource level4 boot script reading document.currentScript.src" do
    get "/domsource/level4/boot.js?msg=x"
    response.status_code.should eq 200
    (response.headers["Content-Type"]? || "").should contain("javascript")
    response.body.should contain("document.currentScript.src")
    response.body.should contain("document.write(msg)")
  end

  it "serves domsource level5 with the sink inside a permissions callback" do
    get "/domsource/level5/?query=a"
    response.status_code.should eq 200
    response.body.should contain("navigator.permissions.query")
  end

  it "serves domsource level6 reading a CSS custom property back out" do
    get "/domsource/level6/"
    response.status_code.should eq 200
    response.body.should contain("setProperty('--maze-label'")
    response.body.should contain("getPropertyValue('--maze-label')")
  end

  it "serves domsource level7 connecting to a real same-origin WebSocket" do
    get "/domsource/level7/?query=a"
    response.status_code.should eq 200
    response.body.should contain("/domsource/level7/echo")
    response.body.should contain("socket.onmessage")
  end

  it "serves domsink level1 with a createHTMLDocument + importNode sink" do
    get "/domsink/level1/?query=a"
    response.status_code.should eq 200
    response.body.should contain("document.implementation.createHTMLDocument")
    response.body.should contain("document.importNode(inert.body, true)")
  end

  it "serves domsink level2 with a DOMParser + adoptNode sink" do
    get "/domsink/level2/?query=a"
    response.status_code.should eq 200
    response.body.should contain("document.adoptNode(parsed.body.firstChild)")
  end

  it "serves domsink level3 with an indirect eval sink" do
    get "/domsink/level3/?query=a"
    response.status_code.should eq 200
    response.body.should contain("(0, eval)(q)")
  end

  it "serves domsink level4 with a Reflect.apply(eval) sink" do
    get "/domsink/level4/?query=a"
    response.status_code.should eq 200
    response.body.should contain("Reflect.apply(eval, globalThis, [q])")
  end

  it "serves domsink level5 with an Array.prototype.map(eval) sink" do
    get "/domsink/level5/?query=a"
    response.status_code.should eq 200
    response.body.should contain(".map(eval)")
  end

  it "serves domsink level6 with an Object.assign(location) navigation sink" do
    get "/domsink/level6/?query=a"
    response.status_code.should eq 200
    response.body.should contain("Object.assign(location, { href: q })")
  end

  it "serves domsink level7 with a setAttributeNS event-handler sink" do
    get "/domsink/level7/?query=a"
    response.status_code.should eq 200
    response.body.should contain("setAttributeNS(null, 'onclick', q)")
  end

  it "serves domsink level8 with a form.action + submit() sink" do
    get "/domsink/level8/?query=a"
    response.status_code.should eq 200
    response.body.should contain("form.action = q")
    response.body.should contain("form.submit()")
  end

  it "serves every taintflow level with its laundering step intact" do
    {
      1 => "JSON.parse(JSON.stringify({ body: q }))",
      2 => "new Proxy({ body: raw }",
      3 => "get body() { return this._value; }",
      4 => "await load(q)",
      5 => "Promise.all([",
      6 => "structuredClone({ payload: { body: q } })",
      7 => "html`<article>${raw}</article>`",
      8 => "template.replace('NAME_SLOT', function () { return q; })",
    }.each do |level, marker|
      get "/taintflow/level#{level}/?query=a"
      response.status_code.should eq 200
      response.body.should contain(marker)
      response.body.should contain("innerHTML")
    end
  end
end

describe "WAF facade levels" do
  it "level1 Cloudflare block page reflects the blocked payload raw" do
    payload = "<script>alert(1)</script>"
    get "/waf-facade/level1/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 403
    response.body.should contain("Cloudflare")
    response.body.should contain(payload)
  end

  it "level1 escapes the reflection on the non-blocked (200) path" do
    get "/waf-facade/level1/?query=#{URI.encode_www_form("hello world")}"
    response.status_code.should eq 200
    response.body.should contain("Results for: hello world")
  end

  it "level2 AWS WAF only inspects the first 100 bytes, so a padded payload slips through" do
    payload = ("a" * 100) + "<svg onload=alert(1)>"
    get "/waf-facade/level2/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("<svg onload=alert(1)>")
  end

  it "level2 AWS WAF blocks a vector that lands inside the inspection window" do
    get "/waf-facade/level2/?query=#{URI.encode_www_form("<svg onload=alert(1)>")}"
    response.status_code.should eq 403
    response.body.should contain("AWS WAF")
  end

  it "level3 CRS scoring lets an un-scored vector under the threshold through" do
    payload = "<input autofocus onfocus=confirm(1)>"
    get "/waf-facade/level3/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(payload)
  end

  it "level3 CRS scoring blocks a high-score payload with mod_security branding" do
    get "/waf-facade/level3/?query=#{URI.encode_www_form("<svg onload=alert(1)>")}"
    response.status_code.should eq 406
    response.body.should contain("Mod_Security")
  end

  it "level4 Akamai reflects the User-Agent header raw while guarding the query" do
    payload = "<img src=x onerror=alert(1)>"
    headers = HTTP::Headers{"User-Agent" => payload}
    get "/waf-facade/level4/?query=a", headers: headers
    response.status_code.should eq 200
    response.body.should contain(payload)
  end

  it "level5 F5 ASM denylist is case-sensitive, so a case-folded vector slips past" do
    payload = "<SvG OnLoad=alert(1)>"
    get "/waf-facade/level5/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(payload)
  end

  it "level5 F5 ASM blocks the lowercase literal and shows a support ID" do
    get "/waf-facade/level5/?query=#{URI.encode_www_form("<svg onload=alert(1)>")}"
    response.status_code.should eq 403
    response.body.should contain("support ID")
  end

  it "level6 Incapsula tag rules miss a JS-string breakout" do
    payload = "';alert(1)//"
    get "/waf-facade/level6/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain("var user = '';alert(1)//';")
  end

  it "level6 Incapsula blocks a tag payload with an incident ID" do
    get "/waf-facade/level6/?query=#{URI.encode_www_form("<img src=x>")}"
    response.status_code.should eq 403
    response.body.should contain("Incapsula incident ID")
  end

  it "level7 cosmetic client-side WAF still reflects raw in the server response" do
    payload = "<img src=x onerror=alert(1)>"
    get "/waf-facade/level7/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.body.should contain(%(<div id='preview'>#{payload}</div>))
  end
end
