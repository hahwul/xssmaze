class Maze
  getter name : String
  getter url : String
  getter desc : String
  getter method : String
  getter params : Array(String)

  def initialize(@name, @url, @desc, @method = "GET", @params = ["query"])
  end

  def type : String
    @name.split("-").first? || "other"
  end

  def to_json_object
    {
      name:   @name,
      url:    @url,
      type:   type,
      desc:   @desc,
      method: @method,
      params: @params,
    }
  end
end
