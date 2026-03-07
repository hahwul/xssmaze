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
end
