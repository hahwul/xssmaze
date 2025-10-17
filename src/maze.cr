class Maze
  @name : String
  @url : String
  @desc : String
  @category : String

  def initialize(@name, @url, @desc, @category = "")
  end

  macro define_getter_methods(names)
    {% for name, index in names %}
      def {{name.id}}
        @{{name.id}}
      end
    {% end %}
  end

  define_getter_methods [name, url, desc, category]
end
