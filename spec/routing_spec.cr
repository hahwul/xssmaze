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
end
