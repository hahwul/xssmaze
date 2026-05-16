require "compress/gzip"

# Catalog of every maze endpoint plus a few shared helpers used by maze
# definitions and the catalog/server layers.
module Xssmaze
  VERSION = "0.1.0"

  @@mazes = [] of Maze
  @@frozen = false

  def self.push(name : String, url : String, desc : String,
                method : String = "GET", params : Array(String) = ["query"])
    raise "maze list is frozen" if @@frozen
    @@mazes << Maze.new(name, url, desc, method, params)
  end

  def self.get : Array(Maze)
    @@mazes
  end

  def self.freeze!
    @@frozen = true
    @@mazes.sort_by!(&.name)
  end

  def self.grouped_mazes : Hash(String, Array(Maze))
    groups = Hash(String, Array(Maze)).new
    @@mazes.each do |maze|
      groups[maze.type] ||= [] of Maze
      groups[maze.type] << maze
    end
    groups
  end

  def self.html_escape(s : String) : String
    s.gsub('&', "&amp;")
      .gsub('<', "&lt;")
      .gsub('>', "&gt;")
      .gsub('"', "&quot;")
      .gsub('\'', "&#39;")
  end

  def self.gzip(body : String) : Bytes
    io = IO::Memory.new
    Compress::Gzip::Writer.open(io, level: Compress::Gzip::BEST_COMPRESSION) do |writer|
      writer.write(body.to_slice)
    end
    io.to_slice.dup
  end
end
