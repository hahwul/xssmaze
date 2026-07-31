class Maze
  # ----- Structured vulnerability metadata -----
  #
  # name/url/desc/method/params tell a tool *where* to send a payload. The
  # fields below tell it *what kind of bug lives there*, so a benchmark can
  # score per vulnerability class without regex-guessing at the served HTML.
  #
  # Four questions must be answerable from /map/json alone:
  #
  #   1. What class of bug is this?             -> `vuln`
  #   2. For DOM flows, taint source and sink?  -> `sources` / `sinks`
  #   3. Can a non-browser scanner even reach
  #      the input, or is it browser-only?      -> `delivery` / `reach`
  #   4. Is this deliberately NOT XSS?          -> `exploitable` / `vuln`
  #
  # Endpoints that are intentionally safe (true negatives) or that are a
  # different bug class entirely (e.g. the `xsleak` cross-site-leak oracles)
  # carry `vuln == "non-xss-control"` and `exploitable == false`, so a
  # benchmark subtracts them instead of counting them as detection misses.

  # Classification rule: classify by the *injection context* — where the
  # bytes actually land — not by what the receiving API does with a
  # well-formed argument. A value the server reflects raw into a JS string
  # literal is `reflected-js` however inert the function it is passed to,
  # because the breakout happens before that function is ever called.
  # `dom` is for flows whose taint reaches a sink through client-side code
  # (either from a client-side source, or from a server-reflected literal
  # that a live DOM sink then executes without needing a breakout).
  #
  # Closed set of `vuln` values. "unclassified" is the default for endpoints
  # that have not been triaged yet — deliberately distinct from
  # "non-xss-control" so unreviewed and reviewed-as-safe never get conflated.
  VULN_CLASSES = %w[
    unclassified
    reflected-html
    reflected-attr
    reflected-js
    dom
    stored
    prototype-pollution
    csti
    non-xss-control
  ]

  # Delivery channels a plain HTTP client can drive on its own. Anything
  # else needs a real browser (or a driver) to place the payload.
  SERVER_CHANNELS = %w[query path body header cookie referer]

  getter name : String
  getter url : String
  getter desc : String
  getter method : String
  getter params : Array(String)

  # Vulnerability class; one of VULN_CLASSES.
  getter vuln : String
  # DOM taint sources, e.g. "location.hash", "postMessage", "localStorage".
  getter sources : Array(String)
  # DOM taint sinks, e.g. "innerHTML", "eval", "location-nav", "srcdoc".
  getter sinks : Array(String)
  # Where the payload enters, e.g. "query", "fragment", "postmessage".
  getter delivery : Array(String)
  # False when the endpoint is a control / true negative.
  getter? exploitable : Bool
  # Free-form caveat: why it is a control, what interaction it needs, etc.
  getter note : String?

  # Category, derived from the name prefix ("basic-level1" -> "basic").
  # Computed once: grouping, /map/json, /map/openapi and /stats each walk
  # every maze, and the old `split("-").first?` allocated an array per call.
  getter type : String

  def initialize(@name, @url, @desc, @method = "GET", @params = ["query"],
                 @vuln = "unclassified",
                 @sources = [] of String,
                 @sinks = [] of String,
                 @delivery = [] of String,
                 @exploitable = true,
                 @note = nil)
    dash = @name.index('-')
    @type = dash ? @name[0, dash] : @name
  end

  # "server"  - the payload fits in the HTTP request (query/path/body/
  #             header/cookie/referer), so a non-browser scanner can reach it.
  # "client"  - the payload only exists browser-side (fragment, postMessage,
  #             clipboard, drag-and-drop, window.name, ...); a request-only
  #             scanner cannot deliver it at all.
  # "unknown" - not triaged.
  def reach : String
    return "unknown" if @delivery.empty?
    @delivery.any? { |channel| SERVER_CHANNELS.includes?(channel) } ? "server" : "client"
  end

  def to_json_object
    {
      name:   @name,
      url:    @url,
      type:   type,
      desc:   @desc,
      method: @method,
      params: @params,
      vuln:   {
        class:       @vuln,
        reach:       reach,
        delivery:    @delivery,
        sources:     @sources,
        sinks:       @sinks,
        exploitable: @exploitable,
        note:        @note,
      },
    }
  end
end
