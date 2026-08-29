require "./spec_helper"

# Post a single form field, the way every stored maze's own form does.
private def post_entry(path : String, field : String, value : String)
  post path,
    headers: HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"},
    body: "#{field}=#{URI.encode_www_form(value)}"
end

private def count_of(haystack : String, needle : String) : Int32
  haystack.split(needle).size - 1
end

describe Xssmaze::Store do
  cap = Xssmaze::Store::MAX_ENTRIES

  before_each { Xssmaze::Store.reset_all }

  describe "the cap" do
    it "keeps only the most recent MAX_ENTRIES entries" do
      (cap + 5).times { |i| post_entry "/stored/level1/", "query", "entry-#{i}" }

      get "/stored/level1/"
      count_of(response.body, "<li>").should eq cap
      # The five oldest were dropped; the newest survived.
      response.body.should_not contain "entry-0"
      response.body.should_not contain "entry-4"
      response.body.should contain "entry-5"
      response.body.should contain "entry-#{cap + 4}"
    end

    it "bounds the callback log group by key as well as by entry" do
      log = Xssmaze::Store.group("headless-generator/level5")

      (cap + 5).times { |i| log.push("id-#{i}", "hit") }
      log.size.should eq cap

      (cap + 5).times { |i| log.push("one-id", "hit-#{i}") }
      log["one-id"].size.should eq cap
      log["one-id"].first.should eq "hit-5"
    end
  end

  describe ".reset_all" do
    it "empties every collection" do
      post_entry "/stored/level1/", "query", "a"
      post_entry "/storedpat/level1/", "body", "b"
      post_entry "/storedpat/level5/", "subject", "c"
      Xssmaze::Store.total.should eq 3

      cleared = Xssmaze::Store.reset_all
      cleared["stored/level1"].should eq 1
      cleared["storedpat/level1"].should eq 1
      cleared["storedpat/level5"].should eq 1
      Xssmaze::Store.total.should eq 0
    end
  end

  describe ".reset" do
    it "clears only the named collection" do
      post_entry "/stored/level1/", "query", "a"
      post_entry "/stored/level2/", "query", "b"

      Xssmaze::Store.reset("stored/level1").should eq 1
      Xssmaze::Store.sizes["stored/level1"].should eq 0
      Xssmaze::Store.sizes["stored/level2"].should eq 1
    end

    it "reports nil for a name nobody registered" do
      Xssmaze::Store.reset("stored/level99").should be_nil
    end
  end

  describe "GET /reset" do
    it "reports sizes without mutating them" do
      post_entry "/stored/level1/", "query", "a"

      get "/reset"
      response.status_code.should eq 200
      response.headers["Cache-Control"]?.should eq "no-store"
      response.headers["Access-Control-Allow-Origin"]?.should eq "*"

      body = JSON.parse(response.body)
      body["max_entries"].as_i.should eq cap
      body["total"].as_i.should eq 1
      body["collections"]["stored/level1"].as_i.should eq 1

      # The status view is the one a crawler hits; it must leave the lab alone.
      Xssmaze::Store.sizes["stored/level1"].should eq 1
    end

    it "lists untouched collections too, not just the ones with entries" do
      get "/reset"
      names = JSON.parse(response.body)["collections"].as_h.keys
      names.should contain "stored/level4"
      names.should contain "storedpat/level6"
      names.should contain "headless-generator/level5"
    end
  end

  describe "POST /reset" do
    it "clears everything and reports what went away" do
      post_entry "/stored/level1/", "query", "a"
      post_entry "/storedpat/level4/", "msg", "b"

      post "/reset"
      response.status_code.should eq 200
      response.headers["Cache-Control"]?.should eq "no-store"

      body = JSON.parse(response.body)
      body["reset"].as_s.should eq "all"
      body["total"].as_i.should eq 2
      body["cleared"]["stored/level1"].as_i.should eq 1

      get "/stored/level1/"
      response.body.should_not contain "<li>"
    end

    it "clears one collection with ?scope=" do
      post_entry "/stored/level1/", "query", "a"
      post_entry "/stored/level2/", "query", "b"

      post "/reset?scope=stored/level1"
      response.status_code.should eq 200
      JSON.parse(response.body)["reset"].as_s.should eq "stored/level1"

      Xssmaze::Store.sizes["stored/level1"].should eq 0
      Xssmaze::Store.sizes["stored/level2"].should eq 1
    end

    it "rejects an unknown scope and names the ones it knows" do
      post "/reset?scope=nope"
      response.status_code.should eq 400
      body = JSON.parse(response.body)
      body["error"].as_s.should eq "unknown scope"
      body["known"].as_a.map(&.as_s).should contain "stored/level1"
    end
  end

  # The regression that matters most: bounding the stores must not have
  # escaped anything on the way in or out. These are the vulnerabilities
  # the lab exists to serve.
  describe "stored mazes still reflect raw payloads" do
    payload = "<script>alert(1)</script>"

    it "reflects raw in /stored/level1/ on POST and on the follow-up GET" do
      post_entry "/stored/level1/", "query", payload
      response.body.should contain "<li>#{payload}</li>"

      get "/stored/level1/"
      response.body.should contain "<li>#{payload}</li>"
    end

    it "reflects raw into the /stored/level3/ title attribute" do
      post_entry "/stored/level3/", "query", payload
      response.body.should contain %(<div title="#{payload}">)
    end

    it "serves raw entries from the /stored/level4/ JSON API" do
      post_entry "/stored/level4/", "query", payload
      get "/stored/level4/api"
      JSON.parse(response.body)["entries"].as_a.map(&.as_s).should eq [payload]
    end

    it "reflects raw into the /storedpat/level1/ title attribute" do
      post_entry "/storedpat/level1/", "body", payload
      response.body.should contain %(<li title="#{payload}">)

      get "/storedpat/level1/"
      response.body.should contain %(<li title="#{payload}">)
    end

    it "reflects raw into the /storedpat/level3/ meta content" do
      post_entry "/storedpat/level3/", "review", payload
      get "/storedpat/level3/"
      response.body.should contain %(content="#{payload}")
    end

    it "reflects raw into the /storedpat/level5/ title and h1" do
      post_entry "/storedpat/level5/", "subject", payload
      get "/storedpat/level5/"
      response.body.should contain "<title>Ticket — #{payload}</title>"
      response.body.should contain "<h1>#{payload}</h1>"
    end

    it "serves the raw /storedpat/level6/ note from its JSON API" do
      post_entry "/storedpat/level6/", "note", payload
      get "/storedpat/level6/api"
      JSON.parse(response.body)["note"].as_s.should eq payload
    end
  end
end
