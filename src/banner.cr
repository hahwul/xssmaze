require "./ui"

# Everything XSSMaze prints before it starts serving: the startup banner,
# `--help`, `--version`, and CLI errors. Kept in one place so the wording and
# the spacing stay consistent.
module Xssmaze::Banner
  TAGLINE  = "Cross-site scripting proving ground"
  HOMEPAGE = "https://github.com/hahwul/xssmaze"

  CATALOG_ROUTES = %w[/map/json /map/text /map/markdown /map/openapi]
  PROBE_ROUTES   = %w[/health /stats /version /random]

  # One mark row plus the text that sits to its right. Rows 0, 3 and 5 are
  # intentionally bare — the air around the identity block is the design.
  private def self.row(io : IO, index : Int32, text : String = "") : Nil
    mark = UI::MARK[index]
    io << "  " << UI.ember(mark)
    unless text.empty?
      io << " " * (UI::MARK_WIDTH - mark.size + 4) << text
    end
    io << '\n'
  end

  private def self.field(io : IO, label : String, value : String) : Nil
    io << UI.dim(label.rjust(10)) << "  " << value << '\n'
  end

  # Printed once, after the CLI has been parsed, so every number and the URL
  # are the real ones this process is about to serve.
  def self.startup(io : IO, url : String, endpoints : Int32, categories : Int32,
                   classified : Int32, exposed : Bool) : Nil
    io << '\n'
    row(io, 0)
    row(io, 1, "#{UI.bold("XSSMaze")} #{UI.dim(Xssmaze::VERSION)}")
    row(io, 2, UI.muted(TAGLINE))
    row(io, 3)
    row(io, 4, UI.dim("#{endpoints} endpoints · #{categories} categories · #{classified} classified"))
    row(io, 5)
    io << '\n'

    field(io, "serving", UI.ember(url))
    field(io, "catalog", UI.muted(CATALOG_ROUTES.join(" · ")))
    field(io, "probes", UI.muted(PROBE_ROUTES.join(" · ")))

    if exposed
      io << '\n' << "  " << UI.paint("!", UI::WARN) << "  "
      io << UI.muted("reachable beyond this machine — XSSMaze is deliberately vulnerable")
      io << '\n'
    end

    io << '\n'
    io.flush
  end

  # A single identity line for contexts where the mark would be noise.
  def self.lockup(io : IO) : Nil
    io << '\n' << "  " << UI.bold("XSSMaze") << " " << UI.dim(Xssmaze::VERSION)
    io << UI.dim("  ·  ") << UI.muted(TAGLINE) << '\n'
  end

  private def self.section(io : IO, title : String) : Nil
    io << '\n' << "  " << UI.dim(title) << '\n'
  end

  private def self.flag(io : IO, spec : String, desc : String, default : String? = nil) : Nil
    io << "    " << spec.ljust(26)
    if default
      io << UI.muted(desc.ljust(28)) << UI.dim(default)
    else
      io << UI.muted(desc)
    end
    io << '\n'
  end

  def self.help(io : IO) : Nil
    lockup(io)

    section(io, "USAGE")
    io << "    xssmaze [options]\n"

    section(io, "SERVER")
    flag(io, "-b, --bind HOST", "address to bind", "127.0.0.1")
    flag(io, "-p, --port PORT", "port to listen on", "3000")
    flag(io, "-s, --ssl", "serve over HTTPS")
    flag(io, "    --ssl-key-file FILE", "private key, PEM encoded")
    flag(io, "    --ssl-cert-file FILE", "certificate, PEM encoded")

    section(io, "OUTPUT")
    flag(io, "-q, --quiet", "do not log requests")
    flag(io, "    --no-banner", "start without the banner")
    flag(io, "    --no-color", "disable ANSI colour")

    section(io, "ABOUT")
    flag(io, "-v, --version", "print the version and exit")
    flag(io, "-h, --help", "print this help and exit")

    io << '\n' << "  " << UI.dim("docs") << "  " << UI.muted(HOMEPAGE) << '\n' << '\n'
    io.flush
  end

  def self.version(io : IO) : Nil
    io << "xssmaze " << Xssmaze::VERSION << '\n'
  end

  # Anything that stops the server before it serves: say what was wrong, then
  # what to try next.
  def self.fail(message : String, hint : String = "try `xssmaze --help`") : NoReturn
    STDERR << '\n' << "  " << UI.paint("!", UI::BAD) << "  " << message << '\n'
    STDERR << "     " << UI.dim(hint) << '\n' << '\n'
    exit 1
  end
end
