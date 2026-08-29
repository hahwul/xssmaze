# Execution oracle.
#
# Every scoring path in this lab measures *reflection*: a scanner asks whether
# its string came back in the HTML and calls that a finding. That is a proxy,
# and a poor one — it scores a harmlessly-escaped echo as a hit, and it is
# blind to the ~160 `dom` endpoints where the payload never reaches the server
# response at all. The beacon replaces the proxy with proof: a payload has to
# actually *run* to reach `/beacon/<token>`, so a hit in the log is a true
# positive that no amount of string matching can fake.
#
#   /basic/level1/?query=<img src=/beacon/run1 onerror=fetch('/beacon/run1')>
#   then: GET /beacon/log?token=run1
#
# The recorded `Referer` is the payoff — it names the maze page that executed,
# so a headless harness can fire one token for a whole sweep and still
# attribute every hit to the endpoint that produced it.
#
# Routes:
#   ANY    /beacon/<token>       record a fire, answer with a 1x1 GIF
#   GET    /beacon/log           the whole log
#   GET    /beacon/log?token=t   one token
#   DELETE /beacon/log           clear it, so consecutive runs are isolated
#   POST   /beacon/log/clear     the same reset for clients that cannot DELETE
#
# This is instrumentation, not a maze, and it is deliberately boring: it never
# calls `Xssmaze.push` (the catalog is a benchmark denominator and must not
# grow a non-maze entry), it answers only `image/gif` and `application/json`,
# and nothing it records is ever echoed into an HTML response.
module Xssmaze::Beacon
  # The canonical 43-byte transparent 1x1 GIF: the smallest thing an
  # `<img src=...>` can load without drawing anything on the page under test.
  GIF_1X1 = Bytes[
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00, 0x00,
    0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x21, 0xF9, 0x04, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x2C, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02,
    0x44, 0x01, 0x00, 0x3B,
  ]

  TOKEN_PATTERN = /\A[A-Za-z0-9_-]{1,64}\z/

  # `/beacon/log` is the log API for every verb, so a token by that name could
  # never be read back. Refusing it up front beats letting a benchmark discover
  # the collision from a permanently empty result.
  RESERVED_TOKENS = %w[log]

  # A fuzzer pointing at `/beacon/<random>` must not be able to exhaust memory,
  # so the log is bounded on all three axes it can grow along: distinct tokens,
  # stored hits per token, and the length kept from each attacker-set header.
  MAX_TOKENS = 1000
  MAX_HITS   =  100
  MAX_VALUE  =  256

  record Hit,
    at : Time,
    method : String,
    referer : String?,
    user_agent : String?

  # One token's history. `count` keeps counting past `MAX_HITS` while `hits`
  # stops growing, so even a capped entry reports the true number of fires.
  class Entry
    getter count : Int32
    getter first_at : Time
    getter last_at : Time
    getter hits : Array(Hit)

    def initialize(hit : Hit)
      @count = 1
      @first_at = hit.at
      @last_at = hit.at
      @hits = [hit]
    end

    def add(hit : Hit) : Nil
      @count += 1
      @last_at = hit.at
      @hits << hit if @hits.size < MAX_HITS
    end

    def truncated? : Bool
      @count > @hits.size
    end
  end

  @@lock = Mutex.new
  @@log = {} of String => Entry
  @@dropped_tokens = 0

  def self.valid_token?(token : String) : Bool
    TOKEN_PATTERN.matches?(token) && !RESERVED_TOKENS.includes?(token)
  end

  # Returns false only when the token cap refused a brand new token. Tokens
  # already in the log keep recording, so a benchmark run in flight is never
  # cut off by someone else fuzzing the beacon.
  def self.record(token : String, method : String,
                  referer : String?, user_agent : String?) : Bool
    hit = Hit.new(Time.utc, method, clip(referer), clip(user_agent))

    @@lock.synchronize do
      if entry = @@log[token]?
        entry.add(hit)
        true
      elsif @@log.size >= MAX_TOKENS
        @@dropped_tokens += 1
        false
      else
        @@log[token] = Entry.new(hit)
        true
      end
    end
  end

  def self.token_json(token : String)
    @@lock.synchronize { entry_json(token, @@log[token]?) }
  end

  def self.log_json
    @@lock.synchronize do
      entries = @@log.map { |token, entry| entry_json(token, entry) }
      {
        tokens:         entries.size,
        total_hits:     @@log.each_value.sum(&.count),
        dropped_tokens: @@dropped_tokens,
        logs:           entries,
      }
    end
  end

  def self.clear
    @@lock.synchronize do
      tokens = @@log.size
      hits = @@log.each_value.sum(&.count)
      @@log.clear
      @@dropped_tokens = 0
      {cleared: true, tokens: tokens, hits: hits}
    end
  end

  # An unknown token is reported rather than 404'd: "this token never fired" is
  # the answer a harness asked for, not an error.
  private def self.entry_json(token : String, entry : Entry?)
    hits = entry.try(&.hits) || [] of Hit
    {
      token:       token,
      fired:       !entry.nil?,
      count:       entry.try(&.count) || 0,
      first:       entry.try(&.first_at.to_rfc3339(fraction_digits: 3)),
      last:        entry.try(&.last_at.to_rfc3339(fraction_digits: 3)),
      referers:    hits.compact_map(&.referer).uniq!,
      user_agents: hits.compact_map(&.user_agent).uniq!,
      truncated:   entry.try(&.truncated?) || false,
      hits:        hits.map do |hit|
        {
          at:         hit.at.to_rfc3339(fraction_digits: 3),
          method:     hit.method,
          referer:    hit.referer,
          user_agent: hit.user_agent,
        }
      end,
    }
  end

  private def self.clip(value : String?) : String?
    return unless value
    value.size > MAX_VALUE ? value[0, MAX_VALUE] : value
  end

  # `no-store` because a cached beacon is a silently lost signal, and the
  # wildcard CORS header because the payload firing it may well be running on
  # another origin. `nosniff` keeps a browser from ever second-guessing the
  # JSON content type and parsing a recorded Referer as markup.
  def self.headers(env) : Nil
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Cache-Control"] = "no-store"
    env.response.headers["X-Content-Type-Options"] = "nosniff"
  end

  def self.json(env) : Nil
    env.response.content_type = "application/json"
    headers(env)
  end

  def self.reject(env) : String
    env.response.status_code = 400
    json(env)
    {error: "invalid token", pattern: "[A-Za-z0-9_-]{1,64}", reserved: RESERVED_TOKENS}.to_json
  end

  def self.preflight(env) : String
    env.response.status_code = 204
    json(env)
    env.response.headers["Access-Control-Allow-Methods"] = "*"
    env.response.headers["Access-Control-Allow-Headers"] = "*"
    ""
  end

  def self.hit(env) : String
    token = env.params.url["token"]
    return reject(env) unless valid_token?(token)

    stored = record(token, env.request.method,
      env.request.headers["Referer"]?.presence,
      env.request.headers["User-Agent"]?.presence)

    env.response.content_type = "image/gif"
    headers(env)
    # A refused token looks exactly like "the payload never ran", so say it out
    # loud instead of letting the harness read a false negative off an empty log.
    env.response.headers["X-Beacon-Log"] = "full" unless stored
    env.response.write(GIF_1X1)
    ""
  end
end

# Kemal's own verb list, so the beacon keeps accepting everything the router
# can route: `<img src>` and `<script src>` send GET, `fetch()` sends whatever
# the payload asked for. HEAD falls back to the GET route inside Kemal.
{% for method in HTTP_METHODS %}
  {% unless method == "options" %}
    {{ method.id }} "/beacon/:token" do |env|
      Xssmaze::Beacon.hit(env)
    end
  {% end %}
{% end %}

# A preflight is the browser asking permission, not the payload firing —
# recording it would double-count every `fetch` that is not CORS-simple.
options "/beacon/:token" do |env|
  Xssmaze::Beacon.preflight(env)
end

options "/beacon/log" do |env|
  Xssmaze::Beacon.preflight(env)
end

get "/beacon/log" do |env|
  Xssmaze::Beacon.json(env)
  if token = env.params.query["token"]?
    next Xssmaze::Beacon.reject(env) unless Xssmaze::Beacon.valid_token?(token)
    Xssmaze::Beacon.token_json(token).to_json
  else
    Xssmaze::Beacon.log_json.to_json
  end
end

delete "/beacon/log" do |env|
  Xssmaze::Beacon.json(env)
  Xssmaze::Beacon.clear.to_json
end

# DELETE is not a CORS-simple method, so a harness page driving the lab from
# another origin would need a preflight to reset between runs. POST does not.
post "/beacon/log/clear" do |env|
  Xssmaze::Beacon.json(env)
  Xssmaze::Beacon.clear.to_json
end
