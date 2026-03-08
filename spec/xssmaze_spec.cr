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
