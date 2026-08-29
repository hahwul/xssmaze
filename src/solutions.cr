require "json"

# Compile-time answer key. The `solutions/` tree carries a ground-truth payload
# and injection context for every maze; embedding it here the way
# `Xssmaze::VERSION` embeds shard.yml keeps the binary self-contained, so the
# Docker image ships the answer key without shipping the directory. Parity with
# the live catalog is enforced by `spec/solutions_spec.cr`, so the two can never
# drift apart again.
module Xssmaze::Solutions
  # One ground-truth entry: how the maze is beaten and where the bytes land.
  struct Solution
    getter payload : String
    getter context : String
    getter url : String

    def initialize(@payload : String, @context : String, @url : String)
    end
  end

  # category (solution-file stem) -> raw markdown, read at compile time. A bare
  # `{ {% for %} ... {% end %} }` can't be recognised as a Hash literal before
  # the loop body expands, so the literal is emitted from a macro instead. `ls`
  # runs on the build host, so `solutions/` must be present at compile time —
  # see `.dockerignore`.
  private macro embed_solutions
    {
      {% for path in `ls "#{__DIR__}/../solutions"`.strip.split('\n') %}
        {% base = path.gsub(/\.md$/, "") %}
        {% if path.ends_with?(".md") && base != "README" %}
          {{ base }} => {{ read_file("#{__DIR__}/../solutions/#{path.id}") }},
        {% end %}
      {% end %}
    }
  end

  # category -> markdown body (what `GET /solutions/<category>` serves).
  MARKDOWN = embed_solutions

  # maze name -> Solution, parsed once at boot from the embedded markdown.
  ENTRIES = begin
    parsed = {} of String => Solution
    MARKDOWN.each_value { |md| parse_into(md, parsed) }
    parsed
  end

  # Every category name that has a markdown page, sorted for stable output.
  def self.categories : Array(String)
    MARKDOWN.keys.sort!
  end

  # Raw markdown for one category, or nil if there is no such page.
  def self.markdown(category : String) : String?
    MARKDOWN[category]?
  end

  # maze name -> Solution.
  def self.entries : Hash(String, Solution)
    ENTRIES
  end

  # Every entry keyed by maze name, for `GET /solutions.json`. Keys are sorted
  # so the body — and therefore its cached ETag — is stable across boots.
  def self.json_body : String
    JSON.build do |json|
      json.object do
        ENTRIES.keys.sort!.each do |name|
          sol = ENTRIES[name]
          json.field name do
            json.object do
              json.field "payload", sol.payload
              json.field "context", sol.context
              json.field "url", sol.url
            end
          end
        end
      end
    end
  end

  # ----- markdown parsing -----
  #
  # An entry is a `### <maze-name>` heading followed (before the next heading)
  # by a backtick URL line and `- payload:` / `- context:` bullets, exactly the
  # shape `solutions/basic.md` documents. Header/POST-only entries carry the
  # payload on a `- header:` / `- body:` line instead, so those stand in when no
  # `- payload:` line is present.
  private HEADING      = /\A###\s+(.+?)\s*\z/
  private URL_LINE     = /\A`([^`]+)`/
  private PAYLOAD_LINE = /\A-\s+payload\b[^:]*:\s*(.*)\z/
  private ALT_LINE     = /\A-\s+(?:header|body)\b[^:]*:\s*(.*)\z/
  private CONTEXT_LINE = /\A-\s+context\s*:\s*(.*)\z/

  private def self.parse_into(md : String, into : Hash(String, Solution)) : Nil
    name = nil.as(String?)
    buf = [] of String

    md.each_line do |raw|
      line = raw.chomp
      if m = line.match(HEADING)
        if n = name
          into[n] = parse_block(buf)
        end
        name = m[1]
        buf = [] of String
      elsif name
        buf << line
      end
    end

    if n = name
      into[n] = parse_block(buf)
    end
  end

  # Pull the URL, payload (or its header/body stand-in) and context out of one
  # entry's body lines. First match of each field wins.
  private def self.parse_block(lines : Array(String)) : Solution
    url = ""
    payload = ""
    alt = ""
    context = ""

    lines.each do |line|
      if url.empty? && (m = line.match(URL_LINE))
        url = m[1]
      elsif payload.empty? && (m = line.match(PAYLOAD_LINE))
        payload = m[1]
      elsif alt.empty? && (m = line.match(ALT_LINE))
        alt = m[1]
      elsif context.empty? && (m = line.match(CONTEXT_LINE))
        context = m[1]
      end
    end

    raw = payload.empty? ? alt : payload
    Solution.new(unwrap(raw), context.strip, url.strip)
  end

  # Payload lines carry the value in a markdown inline-code span, sometimes with
  # a trailing note; return the span's contents. Handles a multi-backtick fence
  # (used when the payload itself contains a backtick, e.g. a template literal)
  # and drops the single surrounding space a code span may carry.
  private def self.unwrap(value : String) : String
    value = value.strip
    return value unless value.starts_with?('`')

    ticks = 0
    while ticks < value.size && value[ticks] == '`'
      ticks += 1
    end
    fence = "`" * ticks
    inner = value[ticks..]
    if idx = inner.rindex(fence)
      inner = inner[0, idx]
    end
    inner = inner[1..] if inner.starts_with?(' ')
    inner = inner[0...-1] if inner.ends_with?(' ')
    inner
  end
end
