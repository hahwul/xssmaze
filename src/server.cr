require "kemal"
require "http"

module Xssmaze::Server
  # Mapping of route path -> catalog key. Keep this table small and
  # data-driven so adding a new catalog asset is a one-line change.
  STATIC_ROUTES = [
    {path: "/", key: "index"},
    {path: "/map/text", key: "map_text"},
    {path: "/map/markdown", key: "map_md"},
    {path: "/map/categories", key: "categories"},
    {path: "/map/openapi", key: "openapi"},
    {path: "/sitemap.xml", key: "sitemap"},
    {path: "/version", key: "version"},
    {path: "/stats", key: "stats"},
    {path: "/payloads", key: "payloads"},
    {path: "/robots.txt", key: "robots"},
    {path: "/assets/index.css", key: "css"},
    {path: "/assets/index.js", key: "js"},
  ]

  # Render a cached Catalog::Entry with ETag/304 + gzip support.
  def self.serve(env, entry : Catalog::Entry, last_modified : String) : String
    env.response.content_type = entry.content_type
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Cache-Control"] = "public, max-age=#{entry.max_age}"
    env.response.headers["Vary"] = "Accept-Encoding"
    env.response.headers["ETag"] = entry.etag
    env.response.headers["Last-Modified"] = last_modified

    if (inm = env.request.headers["If-None-Match"]?) && inm == entry.etag
      env.response.status_code = 304
      return ""
    end

    ae = env.request.headers["Accept-Encoding"]?
    if ae && ae.includes?("gzip")
      env.response.headers["Content-Encoding"] = "gzip"
      env.response.write(entry.gz)
      ""
    else
      entry.body
    end
  end

  # Narrow the catalog by the /map/json filter params. Returns the surviving
  # indices so the caller can reuse the pre-materialized JSON objects instead
  # of rebuilding them.
  def self.filter_indices(mazes : Array(Maze), env) : Array(Int32)
    idx = (0...mazes.size).to_a
    if type = env.params.query["type"]?
      idx = idx.select { |i| mazes[i].type == type }
    end
    if needle = env.params.query["q"]?
      n = needle.downcase
      idx = idx.select do |i|
        mazes[i].name.downcase.includes?(n) || mazes[i].desc.downcase.includes?(n)
      end
    end
    if vuln = env.params.query["vuln"]?
      idx = idx.select { |i| mazes[i].vuln == vuln }
    end
    if reach = env.params.query["reach"]?
      idx = idx.select { |i| mazes[i].reach == reach }
    end
    if exploitable = env.params.query["exploitable"]?
      want = exploitable != "false" && exploitable != "0"
      idx = idx.select { |i| mazes[i].exploitable? == want }
    end
    idx
  end

  FILTER_PARAMS = %w[type q vuln reach exploitable]

  def self.json_no_store(env)
    env.response.content_type = "application/json"
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Cache-Control"] = "no-store"
  end

  # Wire up every "catalog" route plus the small handful of dynamic ones.
  def self.start!(run_server : Bool = true)
    # 1. Tighten Kemal defaults BEFORE Kemal.run parses CLI flags.
    #
    #    Kemal's built-in default binds to 0.0.0.0, which would expose this
    #    intentionally-vulnerable lab to the whole local network. Default to
    #    loopback; users who want network exposure (Docker port mapping)
    #    pass `-b 0.0.0.0` explicitly. Default env is also overridden to
    #    production so the exception handler doesn't render verbose 500
    #    pages with stack traces and source snippets.
    Kemal.config.host_binding = "127.0.0.1"
    Kemal.config.env = "production" unless ENV["KEMAL_ENV"]?

    Xssmaze.freeze!
    catalog = Catalog.build_all
    mazes = Xssmaze.get
    maze_json_objs = mazes.map(&.to_json_object)

    start_time = Time.utc
    server_header = "XSSMaze/#{Xssmaze::VERSION}"
    last_modified = HTTP.format_time(start_time)

    before_all do |env|
      env.response.headers["Server"] = server_header
    end

    after_all do |env|
      Xssmaze::SecurityHeaders.apply_overrides(env.response.headers, env.params.query)
    end

    STATIC_ROUTES.each do |route|
      path = route[:path]
      key = route[:key]
      entry = catalog[key]
      get path do |env|
        Xssmaze::Server.serve(env, entry, last_modified)
      end
    end

    get "/health" do |env|
      json_no_store(env)
      uptime = (Time.utc - start_time).total_seconds.to_i
      {status: "ok", uptime_seconds: uptime, endpoints: mazes.size}.to_json
    end

    # k8s-style alias.
    get "/healthz" do |env|
      json_no_store(env)
      uptime = (Time.utc - start_time).total_seconds.to_i
      {status: "ok", uptime_seconds: uptime, endpoints: mazes.size}.to_json
    end

    # Filter the pre-materialized JSON objects rather than rebuilding tuples.
    map_json_entry = catalog["map_json"]
    get "/map/json" do |env|
      if FILTER_PARAMS.none? { |p| env.params.query[p]? }
        next Xssmaze::Server.serve(env, map_json_entry, last_modified)
      end

      env.response.content_type = "application/json"
      env.response.headers["Access-Control-Allow-Origin"] = "*"
      env.response.headers["Cache-Control"] = "public, max-age=60"
      env.response.headers["Vary"] = "Accept-Encoding"

      filtered_objs = Xssmaze::Server.filter_indices(mazes, env).map { |i| maze_json_objs[i] }
      {endpoints: filtered_objs, total: filtered_objs.size}.to_json
    end

    # Pick a random maze and 302 to it. Useful for lab demos and fuzzers
    # that want to rotate targets without parsing the catalog.
    get "/random" do |env|
      pick = mazes.sample
      env.response.headers["Cache-Control"] = "no-store"
      env.redirect pick.url
    end

    error 404 do |env|
      env.response.content_type = "text/html; charset=utf-8"
      path = env.request.path
      "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>404 - XSSMaze</title>" \
      "<style>body{font-family:-apple-system,sans-serif;max-width:720px;margin:60px auto;padding:0 20px;color:#333}" \
      "h1{margin-bottom:6px}.path{background:#f4f4f4;padding:2px 6px;border-radius:3px;font-family:monospace;color:#c7254e}" \
      "a{color:#0366d6;text-decoration:none}a:hover{text-decoration:underline}</style></head><body>" \
      "<h1>404</h1><p>No maze at <span class='path'>#{Xssmaze.html_escape(path)}</span>.</p>" \
      "<p>Try the <a href='/'>index</a>, the <a href='/map/text'>text map</a>, or the " \
      "<a href='/map/categories'>category list</a>.</p></body></html>"
    end

    # spec-kemal expects Kemal's handler chain to be wired even when we
    # don't call Kemal.run (test mode).
    Kemal.config.setup

    Kemal.run if run_server
  end
end
