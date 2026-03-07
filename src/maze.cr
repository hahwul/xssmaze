class Maze
  getter name : String
  getter url : String
  getter desc : String

  def initialize(@name, @url, @desc)
  end

  def type : String
    @name.split("-").first? || "other"
  end
end
