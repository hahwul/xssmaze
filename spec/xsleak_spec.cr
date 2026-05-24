require "./spec_helper"

require "http"
require "kemal"

require "../src/registry"
require "../src/route_helper"
require "../src/mazes/xsleak"

describe "XS-Leaks scenarios" do
  it "registers maze entries" do
    xsleaks = Xssmaze.get.select { |maze| maze.type == "xsleak" }
    xsleaks.size.should eq(5)

    xsleaks.map(&.name).should contain("xsleak-level1")
    xsleaks.map(&.name).should contain("xsleak-level2")
    xsleaks.map(&.name).should contain("xsleak-level3")
    xsleaks.map(&.name).should contain("xsleak-level4")
    xsleaks.map(&.name).should contain("xsleak-level5")

    xsleaks.each do |maze|
      maze.method.should eq("GET")
      maze.params.should eq(["q"])
    end
  end
end

