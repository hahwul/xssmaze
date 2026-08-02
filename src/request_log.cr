require "http"
require "./ui"

# Request logging, in place of Kemal's `Log`-based handler. One line per
# request, columns that stay put, and the status code carrying the colour:
#
#   14:02:11  200  GET     /basic/level1/?query=a            1.2ms
module Xssmaze
  class RequestLog
    include HTTP::Handler

    # Wide enough for a typical maze path plus a short payload; longer
    # resources push the timing column right instead of wrapping the line.
    PATH_COLUMN = 46
    PATH_LIMIT  = 76

    def initialize(@io : IO = STDOUT)
    end

    def call(context : HTTP::Server::Context)
      elapsed = Time.measure { call_next(context) }
      write(context.response.status_code, context.request.method, context.request.resource, elapsed)
      context
    end

    private def write(status : Int32, method : String, resource : String, elapsed : Time::Span) : Nil
      line = String.build do |io|
        io << "  " << UI.dim(Time.local.to_s("%H:%M:%S"))
        io << "  " << UI.paint(status.to_s, status_color(status))
        io << "  " << UI.dim(method.ljust(6))
        io << ' ' << truncate(resource).ljust(PATH_COLUMN)
        io << "  " << UI.dim(elapsed_text(elapsed))
      end

      @io.puts(line)
      @io.flush
    end

    private def status_color(status : Int32) : String
      case status
      when .< 300 then UI::OK
      when .< 400 then UI::INERT
      when .< 500 then UI::EMBER
      else             UI::BAD
      end
    end

    private def truncate(resource : String) : String
      return resource if resource.size <= PATH_LIMIT
      "#{resource[0, PATH_LIMIT - 1]}…"
    end

    private def elapsed_text(elapsed : Time::Span) : String
      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1
      "#{(millis * 1000).round(2)}µs"
    end
  end
end
