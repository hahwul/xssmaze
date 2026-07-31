require "compress/gzip"
require "html"

# Catalog of every maze endpoint plus a few shared helpers used by maze
# definitions and the catalog/server layers.
module Xssmaze
  # Single source of truth: read the version straight from shard.yml at compile
  # time so it can never drift from the released version again.
  VERSION = {{ read_file("#{__DIR__}/../shard.yml").lines.find(&.starts_with?("version:")).split(":")[1].strip }}

  @@mazes = [] of Maze
  @@frozen = false

  # `name`/`url`/`desc`/`method`/`params` are the original positional
  # contract and must stay put — every existing call site depends on it.
  # Everything after `params` is structured vulnerability metadata, passed
  # by keyword; see `Maze` for the schema. Omitting them leaves the endpoint
  # "unclassified" rather than silently guessing.
  def self.push(name : String, url : String, desc : String,
                method : String = "GET", params : Array(String) = ["query"],
                vuln : String = "unclassified",
                sources : Array(String) = [] of String,
                sinks : Array(String) = [] of String,
                delivery : Array(String) = [] of String,
                exploitable : Bool = true,
                note : String? = nil)
    raise "maze list is frozen" if @@frozen
    @@mazes << Maze.new(name, url, desc, method, params,
      vuln, sources, sinks, delivery, exploitable, note)
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

  # Escapes & < > " ' — byte-for-byte what the previous hand-rolled chain of
  # five `gsub`s produced, in a single pass instead of five intermediates.
  def self.html_escape(s : String) : String
    HTML.escape(s)
  end

  # Strip CR/LF/NUL from a value before it goes into a response header.
  #
  # This is NOT the lab going soft on itself. Crystal's `HTTP::Headers`
  # raises `ArgumentError` on a control character, so a payload like
  # `?query=a%0d%0aX-Evil:1` never produced a split response — it produced a
  # 500 and a stack trace, killing the maze's real lesson (the value *is*
  # still reflected into the header, which is what header-context tests
  # need). Sanitizing here keeps the reflection and drops the crash.
  def self.header_value(s : String) : String
    s.delete("\r\n\u0000")
  end

  def self.gzip(body : String) : Bytes
    io = IO::Memory.new
    Compress::Gzip::Writer.open(io, level: Compress::Gzip::BEST_COMPRESSION) do |writer|
      writer.write(body.to_slice)
    end
    io.to_slice.dup
  end
end
