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
end
