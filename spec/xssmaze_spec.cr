require "./spec_helper"

describe Maze do
  it "extracts type from name" do
    maze = Maze.new("basic-level1", "/basic/level1/?query=a", "no escape")
    maze.type.should eq("basic")
  end

  it "handles name without hyphen" do
    maze = Maze.new("standalone", "/standalone/", "desc")
    maze.type.should eq("standalone")
  end

  it "uses default method and params" do
    maze = Maze.new("basic-level1", "/basic/level1/?query=a", "no escape")
    maze.method.should eq("GET")
    maze.params.should eq(["query"])
  end

  it "accepts custom method and params" do
    maze = Maze.new("post-level1", "/post/level1/", "POST form", "POST", ["body"])
    maze.method.should eq("POST")
    maze.params.should eq(["body"])
  end

  it "generates json object with metadata" do
    maze = Maze.new("basic-level1", "/basic/level1/?query=a", "no escape")
    obj = maze.to_json_object
    obj[:name].should eq("basic-level1")
    obj[:type].should eq("basic")
    obj[:method].should eq("GET")
    obj[:params].should eq(["query"])
  end

  it "defaults vulnerability metadata to unclassified with unknown reach" do
    maze = Maze.new("basic-level1", "/basic/level1/?query=a", "no escape")
    maze.vuln.should eq("unclassified")
    maze.sources.should be_empty
    maze.sinks.should be_empty
    maze.delivery.should be_empty
    maze.exploitable.should be_true
    maze.note.should be_nil
    maze.reach.should eq("unknown")
  end

  it "derives reach=server when any delivery channel fits an HTTP request" do
    maze = Maze.new("dom-level8", "/dom/level8/", "innerHTML (query param)", "GET", ["query"],
      "dom", ["location.search"], ["innerHTML"], ["query"])
    maze.reach.should eq("server")
  end

  it "derives reach=client when the payload only exists browser-side" do
    maze = Maze.new("dom-level7", "/dom/level7/", "innerHTML (location.hash)", "GET", ["#hash"],
      "dom", ["location.hash"], ["innerHTML"], ["fragment"])
    maze.reach.should eq("client")
  end

  it "marks controls as non-exploitable" do
    maze = Maze.new("xsleak-level1", "/xsleak/search?q=admin", "body size oracle", "GET", ["q"],
      "non-xss-control", [] of String, [] of String, ["query"], false, "cross-site leak, not XSS")
    maze.exploitable.should be_false
    maze.vuln.should eq("non-xss-control")
    maze.note.should eq("cross-site leak, not XSS")
  end

  it "serializes vulnerability metadata under a vuln object" do
    maze = Maze.new("dom-level7", "/dom/level7/", "innerHTML (location.hash)", "GET", ["#hash"],
      "dom", ["location.hash"], ["innerHTML"], ["fragment"])
    vuln = maze.to_json_object[:vuln]
    vuln[:class].should eq("dom")
    vuln[:reach].should eq("client")
    vuln[:sources].should eq(["location.hash"])
    vuln[:sinks].should eq(["innerHTML"])
    vuln[:delivery].should eq(["fragment"])
    vuln[:exploitable].should be_true
  end

  it "keeps every declared vuln class inside the closed set" do
    Maze::VULN_CLASSES.should contain("unclassified")
    Maze::VULN_CLASSES.should contain("non-xss-control")
    Maze::VULN_CLASSES.should contain("prototype-pollution")
  end
end

describe "maze catalog vulnerability metadata" do
  it "only uses vuln classes from the closed set" do
    Xssmaze.get.each do |maze|
      Maze::VULN_CLASSES.should contain(maze.vuln)
    end
  end

  it "keeps non-xss-control and exploitable=false in sync" do
    Xssmaze.get.each do |maze|
      if maze.vuln == "non-xss-control"
        maze.exploitable.should be_false
      end
      maze.exploitable.should be_true if maze.vuln == "unclassified"
    end
  end

  it "requires a note explaining every control" do
    Xssmaze.get.reject(&.exploitable).each do |maze|
      maze.note.should_not be_nil
    end
  end

  it "gives every classified endpoint a delivery channel" do
    Xssmaze.get.reject { |maze| maze.vuln == "unclassified" }.each do |maze|
      maze.delivery.should_not be_empty
      maze.reach.should_not eq("unknown")
    end
  end

  it "gives every dom-class endpoint at least one source and one sink" do
    Xssmaze.get.select { |maze| maze.vuln == "dom" }.each do |maze|
      maze.sources.should_not be_empty
      maze.sinks.should_not be_empty
    end
  end
end

describe Filters do
  it "strips angle brackets" do
    Filters.strip_angles("<script>alert(1)</script>").should eq("scriptalert(1)/script")
  end

  it "escapes double quotes" do
    Filters.escape_double_quote("a\"b").should eq("a&quot;b")
  end

  it "escapes single quotes" do
    Filters.escape_single_quote("a'b").should eq("a&quot;b")
  end

  it "escapes all quotes" do
    Filters.escape_quotes("a\"b'c").should eq("a&quot;b&quot;c")
  end

  it "strips parentheses" do
    Filters.strip_parens("alert(1)").should eq("alert1")
  end

  it "strips spaces" do
    Filters.strip_spaces("a b c").should eq("abc")
  end

  it "strips keyword case-insensitively" do
    Filters.strip_keyword_ci("<ScRiPt>alert(1)</sCrIpT>", "script").should eq("<>alert(1)</>")
  end

  it "strips keyword recursively" do
    # Recursive removal: "<scrscriptipt>" -> remove "script" -> "<script>" -> remove again -> "<>"
    Filters.strip_keyword_recursive("<scrscriptipt>alert(1)", "script").should eq("<>alert(1)")
    # Handles nested case where inner removal reveals new match
    Filters.strip_keyword_recursive("scscriptript", "script").should eq("")
  end

  it "strips blacklisted tags" do
    Filters.strip_tags("<script>alert(1)</script><b>safe</b>", ["script"]).should eq("alert(1)<b>safe</b>")
  end

  it "whitelists allowed tags" do
    Filters.whitelist_tags("<b>ok</b><script>bad</script><i>ok</i>", ["b", "i"]).should eq("<b>ok</b>bad<i>ok</i>")
  end

  it "strips event handlers" do
    Filters.strip_event_handlers("<img onerror=alert(1)>").should eq("<img alert(1)>")
  end

  it "strips javascript: protocol" do
    Filters.strip_js_protocol("javascript:alert(1)").should eq("alert(1)")
    Filters.strip_js_protocol("JAVASCRIPT:alert(1)").should eq("alert(1)")
  end

  it "encodes angle brackets as HTML entities" do
    Filters.encode_angles("<script>").should eq("&lt;script&gt;")
  end
end
