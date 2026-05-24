require "http"

macro maze_get(path, &block)
  get {{ path }} {{ block }}
  {% if path.ends_with?("/") %}
    get {{ path[0...-1] }} {{ block }}
  {% end %}
end

macro maze_post(path, &block)
  post {{ path }} {{ block }}
  {% if path.ends_with?("/") %}
    post {{ path[0...-1] }} {{ block }}
  {% end %}
end

module Xssmaze::SecurityHeaders
  def self.apply_overrides(headers : HTTP::Headers, query : HTTP::Params) : Nil
    if (csp = query["set_csp"]?) && !(csp = csp.strip).empty?
      headers["Content-Security-Policy"] = csp
    end

    if (xcto = query["set_xcto"]?) && !(xcto = xcto.strip).empty?
      headers["X-Content-Type-Options"] = normalize_xcto(xcto)
    end

    if (xfo = query["set_xfo"]?) && !(xfo = xfo.strip).empty?
      headers["X-Frame-Options"] = normalize_xfo(xfo)
    end
  end

  private def self.normalize_xcto(value : String) : String
    value.downcase == "nosniff" ? "nosniff" : value
  end

  private def self.normalize_xfo(value : String) : String
    case value.downcase
    when "deny", "sameorigin"
      value.upcase
    else
      value
    end
  end
end
