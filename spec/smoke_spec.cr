require "./spec_helper"

# The catalog is ~1000 hand-written handlers and nothing else walks all of
# them, so a maze that crashes on the exact payload it advertises can sit
# there for releases — three of them did, all dying inside `HTTP::Cookie`.
#
# The assertion is deliberately only "not 5xx". 403/406 (the `waf-facade`
# and `modern-bypass` WAF levels), 302/404 (`redirect-*` pointing at a path
# that does not exist) and 400 are correct answers here; pinning 200 would
# turn this into a tripwire for every intentional behaviour in the lab.
module SmokeSpec
  # Small on purpose: this runs against every parameter of every endpoint,
  # so each extra payload costs a full sweep. These five cover the contexts
  # that break server-side — HTML breakout, JS-string breakout, and the
  # `;` `"` that RFC 6265 bans from a cookie value.
  PAYLOADS = [
    "\"><script>alert(1)</script>",
    "';alert(1);//",
    "a;b",
    "\"x\"",
    "<img src=x onerror=alert(1)>",
  ]

  # How many offenders to spell out before summarising; a broken shared
  # helper can fail hundreds of endpoints at once.
  MAX_REPORTED = 25

  # Params a plain HTTP request cannot carry: fragments (`#hash`), the path
  # placeholder the catalog URL already spells out (`:path`), and browser-only
  # channels (`document.cookie`, `window.name`, `postMessage`).
  def self.carriable?(param : String) : Bool
    return false if param.starts_with?('#') || param.starts_with?(':')
    return false if param.starts_with?("document.") || param.starts_with?("window.")
    param != "postMessage"
  end

  # `params` is hand-maintained and drifts: 25 catalog entries advertise a URL
  # whose real parameter is not in the list — `rsplit-level4` says `query`
  # while the sink is `pref`. Two of the three cookie 500s this spec exists
  # for hid behind exactly that gap, so sweep the union of what the maze
  # declares and what its advertised URL actually spells out.
  def self.params_for(maze : Maze) : Array(String)
    names = [] of String
    _, _, query = maze.url.partition('?')
    HTTP::Params.parse(query).each { |name, _| names << name }
    (names + maze.params).uniq.select { |param| carriable?(param) }
  end

  # A catalog param spelled in Header-Case names an HTTP header rather than a
  # query parameter — `User-Agent`, `Referer`, `X-Forwarded-For` and friends.
  def self.header_param?(param : String) : Bool
    param[0].ascii_uppercase?
  end

  def self.with_query(url : String, param : String, value : String) : String
    path, _, query = url.partition('?')
    params = HTTP::Params.parse(query)
    params[param] = value
    "#{path}?#{params}"
  end

  def self.mazes : Array(Maze)
    Xssmaze.get.select { |maze| maze.method == "GET" }
  end

  # Records the maze name, the status and the exact URL (plus the header, when
  # the payload rode in one) so a CI log alone is enough to reproduce.
  def self.check(failures : Array(String), maze : Maze, url : String,
                 header : String? = nil, payload : String? = nil) : Nil
    headers = nil
    if header && payload
      headers = HTTP::Headers.new
      headers[header] = payload
    end

    get url, headers: headers
    status = response.status_code
    return if status < 500

    via = header ? " (#{header}: #{payload})" : ""
    failures << "#{maze.name}: HTTP #{status} for #{url}#{via}"
  end

  def self.report(failures : Array(String)) : Nil
    return if failures.empty?

    fail(String.build do |io|
      io << failures.size << " endpoint(s) answered 5xx:\n"
      failures.first(MAX_REPORTED).each { |line| io << "  " << line << '\n' }
      if (extra = failures.size - MAX_REPORTED) > 0
        io << "  ...and " << extra << " more\n"
      end
    end)
  end
end

describe "catalog smoke test" do
  it "answers every advertised GET URL without a 5xx" do
    failures = [] of String
    SmokeSpec.mazes.each do |maze|
      SmokeSpec.check(failures, maze, maze.url)
    end
    SmokeSpec.report(failures)
  end

  # `/sitemap.xml` publishes paths with the query string stripped, and a scanner
  # that fuzzes one parameter at a time never sends the others. Both shapes used
  # to reach a non-optional `env.params.query["x"]` and come back 500 — 768 of
  # 1031 GET mazes did, which is what a crawler saw before it fuzzed anything.
  # The sweep below layers its payload on top of `maze.url`, so `?query=a` is
  # always along for the ride and neither shape is covered there.
  it "answers a bare path, with no query string at all, without a 5xx" do
    failures = [] of String
    SmokeSpec.mazes.each do |maze|
      SmokeSpec.check(failures, maze, maze.url.partition('?').first)
    end
    SmokeSpec.report(failures)
  end

  it "answers each parameter sent on its own, with no siblings, without a 5xx" do
    failures = [] of String

    SmokeSpec.mazes.each do |maze|
      params = SmokeSpec.params_for(maze)
      # One parameter alone is what the sweep above already covers once the
      # sibling defaults exist; the point here is levels that declare several.
      next if params.size < 2

      path = maze.url.partition('?').first
      params.each do |param|
        next if SmokeSpec.header_param?(param)
        SmokeSpec.check(failures, maze, SmokeSpec.with_query(path, param, SmokeSpec::PAYLOADS.first))
      end
    end

    SmokeSpec.report(failures)
  end

  it "survives the canonical payloads on every GET parameter" do
    failures = [] of String

    SmokeSpec.mazes.each do |maze|
      SmokeSpec.params_for(maze).each do |param|
        SmokeSpec::PAYLOADS.each do |payload|
          if SmokeSpec.header_param?(param)
            SmokeSpec.check(failures, maze, maze.url, header: param, payload: payload)
          else
            SmokeSpec.check(failures, maze, SmokeSpec.with_query(maze.url, param, payload))
          end
        end
      end
    end

    SmokeSpec.report(failures)
  end
end

# The sweep above only asserts "not 5xx", which a future refactor could
# satisfy by dropping the cookie altogether — and the cookie *is* the maze.
# These pin the other half of the contract: sanitized value in `Set-Cookie`,
# untouched payload in the body.
describe "Xssmaze.cookie_value" do
  it "removes exactly the characters HTTP::Cookie refuses" do
    ((0..0x7f).map(&.chr) + ['한', 'é', '\u{1f4a9}']).each do |char|
      accepted =
        begin
          HTTP::Cookie.new("probe", char.to_s)
          true
        rescue IO::Error
          false
        end

      Xssmaze.cookie_value(char.to_s).should eq(accepted ? char.to_s : "")
    end
  end
end

describe "mazes that reflect into Set-Cookie" do
  payload = "\"><script>alert(1)</script>"
  # `"` is the only byte RFC 6265 bans in the payload above.
  in_cookie = "><script>alert(1)</script>"

  it "respheader level4 keeps both cookies and the raw body reflection" do
    get "/respheader/level4/?query=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.cookies["session_data"].value.should eq(in_cookie)
    response.cookies["user_pref"].value.should eq(in_cookie)
    response.body.should contain(payload)
  end

  it "rsplit level4 survives the splitting characters it exists to reflect" do
    get "/rsplit/level4/?pref=#{URI.encode_www_form(%("x"))}"
    response.status_code.should eq 200
    response.cookies["pref"].value.should eq("x")
    response.body.should contain(%(Preference: "x"))
  end

  it "rsplit level4 drops CR/LF instead of splitting the response" do
    get "/rsplit/level4/?pref=#{URI.encode_www_form("a\r\nX-Evil: 1")}"
    response.status_code.should eq 200
    response.cookies["pref"].value.should eq("aX-Evil: 1")
    response.headers.has_key?("X-Evil").should be_false
  end

  it "realworld-input level6 stores the language and reflects it raw" do
    get "/realworld-input/level6/?lang=#{URI.encode_www_form(payload)}"
    response.status_code.should eq 200
    response.cookies["lang"].value.should eq(in_cookie)
    response.body.should contain("Current language: #{payload}")
  end
end
