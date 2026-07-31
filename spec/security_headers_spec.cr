require "./spec_helper"
require "../src/route_helper"

describe Xssmaze::SecurityHeaders do
  it "sets Content-Security-Policy from query param" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_csp=default-src+%27self%27")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["Content-Security-Policy"].should eq("default-src 'self'")
  end

  it "normalizes X-Content-Type-Options nosniff" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_xcto=NoSnIfF")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["X-Content-Type-Options"].should eq("nosniff")
  end

  it "normalizes X-Frame-Options deny" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_xfo=deny")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["X-Frame-Options"].should eq("DENY")
  end

  it "leaves existing headers when params absent" do
    headers = HTTP::Headers{"X-Frame-Options" => "SAMEORIGIN"}
    query = HTTP::Params.parse("")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["X-Frame-Options"].should eq("SAMEORIGIN")
  end

  it "ignores empty override values" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_xfo=")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers.has_key?("X-Frame-Options").should be_false
  end

  # Regression: a CRLF in any override used to raise ArgumentError out of the
  # `after_all` filter and turn the whole request into a 500.
  it "strips CRLF from override values instead of raising" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_csp=default-src+%27self%27%0d%0aX-Evil%3A+1")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["Content-Security-Policy"].should eq("default-src 'self'X-Evil: 1")
    headers.has_key?("X-Evil").should be_false
  end

  it "drops an override that is only control characters" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_xfo=%0d%0a")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers.has_key?("X-Frame-Options").should be_false
  end

  it "preserves inner spaces in a CSP value" do
    headers = HTTP::Headers.new
    query = HTTP::Params.parse("set_csp=default-src+%27none%27%3B+script-src+%27self%27")

    Xssmaze::SecurityHeaders.apply_overrides(headers, query)

    headers["Content-Security-Policy"].should eq("default-src 'none'; script-src 'self'")
  end
end

describe Xssmaze do
  describe ".header_value" do
    it "removes CR, LF and NUL but nothing else" do
      Xssmaze.header_value("a\r\nb c").should eq("ab c")
      Xssmaze.header_value("plain").should eq("plain")
      Xssmaze.header_value("default-src 'self'").should eq("default-src 'self'")
    end
  end

  describe ".html_escape" do
    it "escapes the five HTML metacharacters" do
      Xssmaze.html_escape(%(&<>"')).should eq("&amp;&lt;&gt;&quot;&#39;")
    end

    it "leaves ordinary and multibyte text untouched" do
      Xssmaze.html_escape("안녕 hello").should eq("안녕 hello")
    end
  end
end
