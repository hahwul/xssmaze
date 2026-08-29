require "./spec_helper"

private def fire(token : String, referer : String? = nil, user_agent : String? = nil)
  headers = HTTP::Headers.new
  headers["Referer"] = referer if referer
  headers["User-Agent"] = user_agent if user_agent
  get "/beacon/#{token}", headers: headers
end

private def read_log(token : String? = nil) : JSON::Any
  get(token ? "/beacon/log?token=#{token}" : "/beacon/log")
  JSON.parse(response.body)
end

describe Xssmaze::Beacon do
  before_each { Xssmaze::Beacon.clear }

  describe "firing" do
    it "records a hit and reports it in the log" do
      fire("run1")
      response.status_code.should eq 200

      log = read_log("run1")
      log["token"].as_s.should eq "run1"
      log["fired"].as_bool.should be_true
      log["count"].as_i.should eq 1
      log["first"].as_s.should_not be_empty
      log["last"].as_s.should eq log["first"].as_s
    end

    it "records the Referer, which names the maze page that executed" do
      page = "http://127.0.0.1:3000/basic/level1/?query=%3Cimg%20src=/beacon/run1%3E"
      fire("run1", referer: page, user_agent: "HeadlessChrome/1.0")

      log = read_log("run1")
      log["referers"].as_a.map(&.as_s).should eq [page]
      log["user_agents"].as_a.map(&.as_s).should eq ["HeadlessChrome/1.0"]
      log["hits"].as_a.first["referer"].as_s.should eq page
      log["hits"].as_a.first["method"].as_s.should eq "GET"
    end

    it "increments the count on a second fire and keeps both Referers" do
      fire("run1", referer: "http://host/a")
      first = read_log("run1")["first"].as_s
      fire("run1", referer: "http://host/b")

      log = read_log("run1")
      log["count"].as_i.should eq 2
      log["first"].as_s.should eq first
      log["referers"].as_a.map(&.as_s).should eq ["http://host/a", "http://host/b"]
    end

    it "reports a token that never fired instead of erroring" do
      log = read_log("never")
      response.status_code.should eq 200
      log["fired"].as_bool.should be_false
      log["count"].as_i.should eq 0
      log["first"].raw.should be_nil
      log["hits"].as_a.should be_empty
    end

    it "keeps tokens apart and lists them all when no token is given" do
      fire("run1")
      fire("run2")
      fire("run2")

      log = read_log
      log["tokens"].as_i.should eq 2
      log["total_hits"].as_i.should eq 3
      log["logs"].as_a.map(&.["token"].as_s).sort!.should eq ["run1", "run2"]
    end

    it "records fires from methods other than GET, so fetch() works" do
      post "/beacon/run1"
      response.status_code.should eq 200
      delete "/beacon/run1"
      put "/beacon/run1"

      log = read_log("run1")
      log["count"].as_i.should eq 3
      log["hits"].as_a.map(&.["method"].as_s).should eq ["POST", "DELETE", "PUT"]
    end

    it "answers a CORS preflight without counting it as a fire" do
      options "/beacon/run1"
      response.status_code.should eq 204
      response.headers["Access-Control-Allow-Origin"]?.should eq "*"
      response.headers["Access-Control-Allow-Methods"]?.should eq "*"

      read_log("run1")["fired"].as_bool.should be_false
    end
  end

  describe "the GIF response" do
    it "is served as image/gif so <img src> triggers a load" do
      fire("run1")
      response.headers["Content-Type"]?.should eq "image/gif"
    end

    it "is a valid 43-byte transparent GIF" do
      fire("run1")
      body = response.body.to_slice

      body.size.should eq Xssmaze::Beacon::GIF_1X1.size
      body.should eq Xssmaze::Beacon::GIF_1X1
      String.new(body[0, 6]).should eq "GIF89a"
      body[-1].should eq 0x3B_u8 # GIF trailer
      # Logical screen descriptor: 1x1, little-endian.
      body[6].should eq 0x01_u8
      body[8].should eq 0x01_u8
      # Graphic control extension with the transparent-colour flag set.
      body[19].should eq 0x21_u8
      body[22].should eq 0x01_u8
    end

    it "is never cached, because a cached beacon is a lost signal" do
      fire("run1")
      response.headers["Cache-Control"]?.should eq "no-store"
      response.headers["Access-Control-Allow-Origin"]?.should eq "*"
    end
  end

  describe "clearing" do
    it "empties the log via DELETE /beacon/log" do
      fire("run1")
      fire("run2")

      delete "/beacon/log"
      response.status_code.should eq 200
      cleared = JSON.parse(response.body)
      cleared["cleared"].as_bool.should be_true
      cleared["tokens"].as_i.should eq 2
      cleared["hits"].as_i.should eq 2

      log = read_log
      log["tokens"].as_i.should eq 0
      log["total_hits"].as_i.should eq 0
      log["logs"].as_a.should be_empty
      read_log("run1")["fired"].as_bool.should be_false
    end

    it "empties the log via POST /beacon/log/clear" do
      fire("run1")
      post "/beacon/log/clear"
      response.status_code.should eq 200
      JSON.parse(response.body)["tokens"].as_i.should eq 1

      read_log["tokens"].as_i.should eq 0
    end
  end

  describe "token validation" do
    it "rejects a token outside [A-Za-z0-9_-] with 400" do
      # Kemal URL-decodes path params, so an encoded slash or NUL is decoded
      # into the token and has to be caught by the pattern, not by the router.
      {"a.b", "a%20b", "a%2Fb", "a%00", "%3Cscript%3E", "tok:1", "a+b"}.each do |token|
        fire(token)
        response.status_code.should eq 400
      end
    end

    it "never reaches the beacon at all when the token spans path segments" do
      fire("a/b")
      response.status_code.should eq 404
      get "/beacon/"
      response.status_code.should eq 404
    end

    it "rejects a token longer than 64 characters with 400" do
      fire("a" * 64)
      response.status_code.should eq 200
      fire("a" * 65)
      response.status_code.should eq 400
    end

    it "rejects the reserved `log` token, which the log API already owns" do
      post "/beacon/log"
      response.status_code.should eq 400
      Xssmaze::Beacon.valid_token?("log").should be_false
    end

    it "rejects an invalid token on the log endpoint too" do
      get "/beacon/log?token=a.b"
      response.status_code.should eq 400
    end

    it "records nothing for a rejected token" do
      fire("a.b")
      read_log["tokens"].as_i.should eq 0
    end

    it "answers a rejection as JSON without echoing the token" do
      fire("%3Cscript%3Ealert(1)%3C%2Fscript%3E")
      response.status_code.should eq 400
      response.headers["Content-Type"]?.should eq "application/json"
      response.body.should_not contain "script"
      JSON.parse(response.body)["error"].as_s.should eq "invalid token"
    end
  end

  describe "not injectable" do
    it "hands back a recorded Referer as JSON data, never as markup" do
      payload = %(http://host/"><script>alert(1)</script>)
      fire("run1", referer: payload, user_agent: payload)

      response.headers["Content-Type"]?.should eq "image/gif"

      log = read_log("run1")
      response.headers["Content-Type"]?.should eq "application/json"
      response.headers["X-Content-Type-Options"]?.should eq "nosniff"
      log["referers"].as_a.first.as_s.should eq payload
      # The quote that would break out of an attribute is escaped in transit.
      response.body.should contain %(\\"><script>)
    end

    it "stays out of the catalog, so benchmark denominators are untouched" do
      Xssmaze.get.any?(&.url.starts_with?("/beacon")).should be_false
      Xssmaze.get.any?(&.name.includes?("beacon")).should be_false
    end

    it "does not let /beacon/log be swallowed by the token route" do
      fire("run1")
      get "/beacon/log"
      response.headers["Content-Type"]?.should eq "application/json"
      JSON.parse(response.body)["tokens"].as_i.should eq 1
    end
  end

  describe "caps" do
    it "stops storing hits past MAX_HITS but keeps counting them" do
      (Xssmaze::Beacon::MAX_HITS + 5).times { fire("run1") }

      log = read_log("run1")
      log["count"].as_i.should eq Xssmaze::Beacon::MAX_HITS + 5
      log["hits"].as_a.size.should eq Xssmaze::Beacon::MAX_HITS
      log["truncated"].as_bool.should be_true
    end

    it "refuses new tokens past MAX_TOKENS and reports the drops" do
      Xssmaze::Beacon::MAX_TOKENS.times do |i|
        Xssmaze::Beacon.record("t#{i}", "GET", nil, nil).should be_true
      end
      Xssmaze::Beacon.record("overflow", "GET", nil, nil).should be_false

      log = read_log
      log["tokens"].as_i.should eq Xssmaze::Beacon::MAX_TOKENS
      log["dropped_tokens"].as_i.should eq 1
      read_log("overflow")["fired"].as_bool.should be_false
    end

    it "keeps recording a known token after the token cap is reached" do
      Xssmaze::Beacon::MAX_TOKENS.times { |i| Xssmaze::Beacon.record("t#{i}", "GET", nil, nil) }
      Xssmaze::Beacon.record("t0", "GET", nil, nil).should be_true

      read_log("t0")["count"].as_i.should eq 2
    end

    it "clips an oversized Referer instead of storing it whole" do
      fire("run1", referer: "http://host/#{"a" * 4096}")

      stored = read_log("run1")["referers"].as_a.first.as_s
      stored.size.should eq Xssmaze::Beacon::MAX_VALUE
    end

    it "tells the caller when a fire was dropped" do
      Xssmaze::Beacon::MAX_TOKENS.times { |i| Xssmaze::Beacon.record("t#{i}", "GET", nil, nil) }

      fire("overflow")
      response.status_code.should eq 200
      response.headers["X-Beacon-Log"]?.should eq "full"

      fire("t0")
      response.headers["X-Beacon-Log"]?.should be_nil
    end
  end
end
