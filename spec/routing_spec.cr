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
end
