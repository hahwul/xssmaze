require "log"

# Presentation tokens for everything XSSMaze prints to a terminal: colour
# detection, the palette, and the brand mark. The palette is lifted straight
# from the web UI (`Assets::INDEX_CSS`) so the CLI and the browser read as the
# same product.
module Xssmaze::UI
  # Truecolor when the terminal advertises it, 256-colour otherwise. Both
  # ladders track the dark-theme tokens, which is what a terminal usually is.
  TRUE_COLOR = {"truecolor", "24bit"}.includes?(ENV["COLORTERM"]?)

  EMBER = TRUE_COLOR ? "38;2;217;133;59" : "38;5;173"  # --ember  #d9853b
  MUTED = TRUE_COLOR ? "38;2;163;156;146" : "38;5;247" # --muted  #a39c92
  DIM   = TRUE_COLOR ? "38;2;128;122;116" : "38;5;243" # --dim    #807a74
  INERT = TRUE_COLOR ? "38;2;127;143;154" : "38;5;109" # --inert  #7f8f9a
  OK    = TRUE_COLOR ? "38;2;122;158;110" : "38;5;108"
  WARN  = TRUE_COLOR ? "38;2;217;164;59" : "38;5;179"
  BAD   = TRUE_COLOR ? "38;2;198;92;79" : "38;5;167"
  BOLD  = "1"

  # Honour NO_COLOR (https://no-color.org) and stay plain when the output is
  # piped into a file or a tool. `--no-color` flips this off explicitly.
  class_property? color : Bool = ENV["NO_COLOR"]?.nil? &&
                                 ENV["TERM"]? != "dumb" &&
                                 STDOUT.tty?

  def self.paint(text : String, sgr : String) : String
    color? ? "\e[#{sgr}m#{text}\e[0m" : text
  end

  def self.ember(text : String) : String
    paint(text, EMBER)
  end

  def self.muted(text : String) : String
    paint(text, MUTED)
  end

  def self.dim(text : String) : String
    paint(text, DIM)
  end

  def self.bold(text : String) : String
    paint(text, BOLD)
  end

  # The brand mark: the same square unicursal spiral as `Assets::FAVICON_SVG`,
  # redrawn on the 7x6 character grid the SVG path already snaps to. The stub
  # at the top right is the exit; the one in the middle is where you start.
  MARK = [
    "┌─────────╴",
    "│ ┌─────┐",
    "│ │ └─┐ │",
    "│ │ ╵ │ │",
    "│ └───┘ │",
    "└───────┘",
  ]

  MARK_WIDTH = 11

  # Kemal's own log output (startup notice, unhandled exceptions). Dropping
  # the ISO timestamp and the `kemal:` source keeps rare messages readable
  # instead of making every line look like a stack trace.
  LOG_FORMATTER = ::Log::Formatter.new do |entry, io|
    sgr = entry.severity >= ::Log::Severity::Error ? BAD : WARN
    io << "  " << paint(entry.severity.label.downcase.ljust(5), sgr) << "  " << entry.message
    if ex = entry.exception
      io << '\n' << ex.inspect_with_backtrace
    end
  end
end
