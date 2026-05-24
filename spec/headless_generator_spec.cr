require "./spec_helper"

describe "Headless Generator XSS" do
  describe "Level 1 - HTML to PDF without filtering" do
    it "reflects user HTML input without sanitization" do
      maze = Maze.new("headless-generator-level1", "/headless-generator/level1/", "HTML to PDF - no filtering", "POST", ["html"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
      maze.params.should eq(["html"])
    end
  end

  describe "Level 2 - SVG to PNG without filtering" do
    it "accepts SVG input for rendering" do
      maze = Maze.new("headless-generator-level2", "/headless-generator/level2/", "SVG to PNG - no filtering", "POST", ["svg"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
      maze.params.should eq(["svg"])
    end
  end

  describe "Level 3 - HTML sanitization with bypass" do
    it "strips script tags but allows other vectors" do
      maze = Maze.new("headless-generator-level3", "/headless-generator/level3/", "HTML sanitization bypass", "POST", ["html"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
    end
  end

  describe "Level 4 - SSRF via resource loading" do
    it "fetches external resources during rendering" do
      maze = Maze.new("headless-generator-level4", "/headless-generator/level4/", "SSRF via resource loading", "POST", ["html"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
    end
  end

  describe "Level 5 - JavaScript callback simulation" do
    it "detects JavaScript execution and logs callbacks" do
      maze = Maze.new("headless-generator-level5", "/headless-generator/level5/", "JavaScript callback simulation", "POST", ["html", "callback_id"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
      maze.params.should eq(["html", "callback_id"])
    end
  end

  describe "Level 6 - Content-Type validation bypass" do
    it "handles JSON and HTML content types" do
      maze = Maze.new("headless-generator-level6", "/headless-generator/level6/", "Content-Type validation bypass", "POST", ["content"])
      maze.type.should eq("headless")
      maze.method.should eq("POST")
      maze.params.should eq(["content"])
    end
  end
end
