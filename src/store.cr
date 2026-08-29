require "json"

# Central registry for the state the stored mazes accumulate.
#
# Stored mazes are the one part of the lab that remembers a scanner run, and
# they used to remember it forever: a second run read the first run's payloads
# back out and reported them as its own finding, two tools pointed at one
# instance contaminated each other, and a long fuzz grew the process without
# bound. Every collection is capped and reachable by name from here, so a
# harness can wipe the lab between runs (`POST /reset`) instead of restarting
# it.
#
# The vulnerabilities themselves are untouched — the cap and the reset are the
# only new behaviour.
module Xssmaze::Store
  # How many entries a bounded collection keeps. Deep enough that a scanner
  # posting a handful of payloads still watches a list build up, shallow
  # enough that a fuzzer cannot grow the process.
  MAX_ENTRIES = 20

  abstract class Collection
    getter name : String

    def initialize(@name : String)
    end

    abstract def size : Int32
    abstract def clear : Nil
  end

  # The most recent `MAX_ENTRIES` values, oldest dropped first.
  class List < Collection
    getter entries = [] of String

    def <<(value : String) : Nil
      @entries << value
      @entries.shift if @entries.size > MAX_ENTRIES
    end

    def size : Int32
      @entries.size
    end

    def clear : Nil
      @entries.clear
    end
  end

  # A single value that every POST overwrites. Bounded by construction; it is
  # registered here so that "clear everything" really does mean everything.
  class Single < Collection
    property value = ""

    def size : Int32
      @value.empty? ? 0 : 1
    end

    def clear : Nil
      @value = ""
    end
  end

  # A bounded map of key -> bounded list, for the store whose keys the maze
  # invents at runtime (a random callback id). Capping only the lists would
  # still leak one key per request forever, so the key set is capped too —
  # Hash keeps insertion order, so the oldest key is always `first_key`.
  class Group < Collection
    @lists = {} of String => Array(String)

    def push(key : String, value : String) : Nil
      list = @lists[key]?
      unless list
        list = @lists[key] = [] of String
        @lists.delete(@lists.first_key) if @lists.size > MAX_ENTRIES
      end
      list << value
      list.shift if list.size > MAX_ENTRIES
    end

    def [](key : String) : Array(String)
      @lists[key]? || [] of String
    end

    def size : Int32
      @lists.values.sum(&.size)
    end

    def clear : Nil
      @lists.clear
    end
  end

  @@collections = {} of String => Collection

  # Register-or-fetch. Maze files call these at require time, so every
  # collection shows up in `sizes` before the first request rather than
  # appearing halfway through a run.
  def self.list(name : String) : List
    (@@collections[name] ||= List.new(name)).as(List)
  end

  def self.single(name : String) : Single
    (@@collections[name] ||= Single.new(name)).as(Single)
  end

  def self.group(name : String) : Group
    (@@collections[name] ||= Group.new(name)).as(Group)
  end

  def self.names : Array(String)
    @@collections.keys.sort!
  end

  def self.sizes : Hash(String, Int32)
    names.each_with_object({} of String => Int32) do |name, acc|
      acc[name] = @@collections[name].size
    end
  end

  def self.total : Int32
    @@collections.values.sum(&.size)
  end

  # Clears one collection and reports how many entries went away, or nil when
  # nothing is registered under that name — the route answers 400 for that.
  def self.reset(name : String) : Int32?
    collection = @@collections[name]?
    return unless collection
    cleared = collection.size
    collection.clear
    cleared
  end

  def self.reset_all : Hash(String, Int32)
    names.each_with_object({} of String => Int32) do |name, acc|
      collection = @@collections[name]
      acc[name] = collection.size
      collection.clear
    end
  end

  # Same headers as `Xssmaze::Server.json_no_store`, spelled out rather than
  # called: the store is required before the server and has no business
  # reaching up into the HTTP layer for three header assignments.
  def self.json_no_store(env) : Nil
    env.response.content_type = "application/json"
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Cache-Control"] = "no-store"
  end
end

# `/reset` is lab infrastructure, not a maze, so it is deliberately absent
# from `Xssmaze.push`: /map/json, /stats and every benchmark denominator
# should count vulnerabilities, not the plumbing that clears them.
#
#   GET  /reset               current size of every collection. Read-only, so
#                             a crawler following links — or a scanner that
#                             GETs every route it discovers — can never wipe
#                             the lab out from under a run in progress.
#   POST /reset               clear everything.
#   POST /reset?scope=<name>  clear one collection, named as `GET /reset`
#                             reports it (e.g. `stored/level1`).
get "/reset" do |env|
  Xssmaze::Store.json_no_store(env)
  {
    collections: Xssmaze::Store.sizes,
    total:       Xssmaze::Store.total,
    max_entries: Xssmaze::Store::MAX_ENTRIES,
  }.to_json
end

post "/reset" do |env|
  Xssmaze::Store.json_no_store(env)

  if scope = env.params.query["scope"]?
    cleared = Xssmaze::Store.reset(scope)
    if cleared.nil?
      # 400, not 404: Kemal hands any 404 to the `error 404` handler, which
      # would replace this JSON with the lab's HTML not-found page. The route
      # exists — the scope is what's wrong — so 400 is the honest answer.
      env.response.status_code = 400
      next {error: "unknown scope", scope: scope, known: Xssmaze::Store.names}.to_json
    end
    {reset: scope, cleared: {scope => cleared}, total: cleared}.to_json
  else
    cleared = Xssmaze::Store.reset_all
    {reset: "all", cleared: cleared, total: cleared.values.sum}.to_json
  end
end
