require "json"
require "digest/sha1"

# Catalog packages every "static" response served from the maze index:
# the HTML landing page, /map/* views, /sitemap.xml, /version, /stats, etc.
# Each entry stores the body, a pre-gzipped copy, and a short ETag, all
# computed once at boot so the request path is just a hash lookup.
module Xssmaze::Catalog
  struct Entry
    getter body : String
    getter gz : Bytes
    getter etag : String
    getter content_type : String
    getter max_age : Int32

    def initialize(body : String, @content_type : String, @max_age : Int32 = 60)
      @body = body
      @gz = Xssmaze.gzip(body)
      @etag = %("#{Digest::SHA1.hexdigest(body)[0, 16]}")
    end
  end

  # ----- Catalog views -----

  def self.build_index_html(groups : Hash(String, Array(Maze)),
                            total : Int32) : String
    maze_list = build_maze_list(groups)
    cat_count = groups.size

    String.build do |io|
      io << "<!DOCTYPE html>\n<html lang='en'>\n<head>\n"
      io << "<meta charset='UTF-8'>\n"
      io << "<meta name='viewport' content='width=device-width, initial-scale=1.0'>\n"
      io << "<title>XSSMaze</title>\n"
      io << "<link rel='stylesheet' href='/assets/index.css'>\n"
      io << "</head>\n<body>\n"
      io << "<div class='header'>\n"
      io << "<h1>XSSMaze</h1>\n"
      io << "<p class='description'>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>\n"
      io << "<p class='description'>Most challenges use <code>query</code>, but some cases use parameters such as <code>callback</code>, <code>query2</code>, <code>seed</code>, <code>blob</code>, <code>url</code>, path segments, or request headers.</p>\n"
      io << "<div class='stats'>\n"
      io << "<span class='stat'><strong>" << total << "</strong> endpoints</span>\n"
      io << "<span class='stat'><strong>" << cat_count << "</strong> categories</span>\n"
      io << "<span class='stat'><strong id='stat-visible'>" << total << "</strong> visible</span>\n"
      io << "<span class='stat'>v" << Xssmaze::VERSION << "</span>\n"
      io << "</div>\n"
      io << "<div class='controls'>\n"
      io << "<input id='search' type='search' placeholder='Filter by name or description (e.g. dom, csp, level3)'>\n"
      io << "</div>\n"
      io << "<div class='map-links'>\n"
      io << "<strong>Endpoints:</strong>\n"
      io << "<a href='/map/text'>text</a>\n"
      io << "<a href='/map/json'>json</a>\n"
      io << "<a href='/map/categories'>categories</a>\n"
      io << "<a href='/map/markdown'>markdown</a>\n"
      io << "<a href='/health'>health</a>\n"
      io << "<a href='/version'>version</a>\n"
      io << "</div>\n</div>\n"
      io << maze_list
      io << "\n<script src='/assets/index.js' defer></script>\n"
      io << "</body>\n</html>"
    end
  end

  private def self.build_maze_list(groups : Hash(String, Array(Maze))) : String
    sorted_types = groups.keys.sort!

    String.build do |io|
      io << "<div class='container'>\n  <ul class='list' id='maze-list'>"
      sorted_types.each do |type|
        type_mazes = groups[type]
        io << "<li class='cat' data-cat='" << type << "'>"
        io << "<span class='cat-name' id='cat-" << type << "'>" << type << "</span>"
        io << " <span class='count'>(" << type_mazes.size << ")</span>"
        io << "<ul class='list'>"
        type_mazes.each do |maze|
          io << "<li class='maze' data-name='" << maze.name.downcase
          io << "' data-desc='" << Xssmaze.html_escape(maze.desc.downcase) << "'>"
          io << "<a href='" << maze.url << "'>" << maze.name << "</a>"
          io << " <span class='method'>" << maze.method << "</span>"
          io << " - " << Xssmaze.html_escape(maze.desc) << "</li>"
        end
        io << "</ul></li>"
      end
      io << "</ul></div>"
    end
  end

  def self.build_map_text(mazes : Array(Maze)) : String
    String.build do |io|
      mazes.each_with_index do |maze, idx|
        io << '\n' if idx > 0
        io << maze.url
      end
    end
  end

  def self.build_map_markdown(mazes : Array(Maze)) : String
    String.build do |io|
      io << "# XSSMaze Endpoints\n\n"
      io << "Total: " << mazes.size << "\n\n"
      io << "| Name | Method | URL | Params | Description |\n"
      io << "|------|--------|-----|--------|-------------|\n"
      mazes.each do |maze|
        io << "| " << maze.name
        io << " | " << maze.method
        io << " | `" << maze.url << "`"
        io << " | `" << maze.params.join(",") << "`"
        io << " | " << maze.desc.gsub("|", "\\|")
        io << " |\n"
      end
    end
  end

  def self.build_categories_json(groups : Hash(String, Array(Maze)),
                                 total : Int32) : String
    arr = groups.keys.sort!.map do |cat|
      {category: cat, count: groups[cat].size}
    end
    {total: total, categories: arr}.to_json
  end

  # Minimal OpenAPI 3.0 document so external tooling (Swagger UI, code
  # generators, scanner runners) can ingest the catalog directly.
  def self.build_openapi(mazes : Array(Maze)) : String
    paths = Hash(String, Hash(String, Hash(String, JSON::Any))).new
    mazes.each do |maze|
      # Strip query string from URL when keying paths.
      path = maze.url.split("?", 2).first
      method = maze.method.downcase
      params_arr = maze.params.map do |param|
        loc = case param
              when ":path" then "path"
              when "Cookie", "Referer", "User-Agent", "Authorization"
                "header"
              else
                "query"
              end
        JSON.parse({name: param, in: loc, required: false,
                    description: "maze input", schema: {type: "string"}}.to_json)
      end
      op = {
        "summary"     => JSON.parse(maze.name.to_json),
        "description" => JSON.parse(maze.desc.to_json),
        "tags"        => JSON.parse([maze.type].to_json),
        "parameters"  => JSON.parse(params_arr.to_json),
        "responses"   => JSON.parse({"200" => {description: "ok"}}.to_json),
      }
      paths[path] ||= Hash(String, Hash(String, JSON::Any)).new
      paths[path][method] = op
    end

    {
      openapi: "3.0.0",
      info:    {
        title:       "XSSMaze",
        version:     Xssmaze::VERSION,
        description: "Intentionally vulnerable XSS lab. Endpoints are reflective by design.",
      },
      paths: paths,
    }.to_json
  end

  def self.build_sitemap(mazes : Array(Maze)) : String
    String.build do |io|
      io << %(<?xml version="1.0" encoding="UTF-8"?>\n)
      io << %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
      mazes.each do |maze|
        path = maze.url.split("?", 2).first
        io << "  <url><loc>" << path << "</loc></url>\n"
      end
      io << "</urlset>\n"
    end
  end

  def self.build_stats(mazes : Array(Maze), groups : Hash(String, Array(Maze))) : String
    methods_count = Hash(String, Int32).new(0)
    params_count = Hash(String, Int32).new(0)
    mazes.each do |maze|
      methods_count[maze.method] += 1
      maze.params.each { |param| params_count[param] += 1 }
    end
    {
      total:      mazes.size,
      categories: groups.size,
      methods:    methods_count,
      params:     params_count.to_a.sort_by! { |(_, v)| -v }.to_h,
    }.to_json
  end

  PAYLOADS_BODY = {
    description: "Reference XSS payloads for lab use only.",
    payloads:    [
      {label: "basic alert", value: "<script>alert(1)</script>"},
      {label: "img onerror", value: "<img src=x onerror=alert(1)>"},
      {label: "svg onload", value: "<svg onload=alert(1)>"},
      {label: "javascript: scheme", value: "javascript:alert(1)"},
      {label: "data: html", value: "data:text/html,<script>alert(1)</script>"},
      {label: "iframe srcdoc", value: "<iframe srcdoc='<script>alert(1)</script>'>"},
      {label: "details ontoggle", value: "<details open ontoggle=alert(1)>"},
      {label: "input autofocus", value: "<input autofocus onfocus=alert(1)>"},
      {label: "form action javascript", value: "<form action=javascript:alert(1)><button>x</button></form>"},
      {label: "polyglot", value: "jaVasCript:/*-/*`/*\\`/*'/*\"/**/(/* */oNcliCk=alert() )//%0D%0A%0D%0A//</stYle/</titLe/</teXtarEa/</scRipt/--!>\\x3csVg/<sVg/oNloAd=alert()//>\\x3e"},
    ],
  }.to_json

  ROBOTS_BODY = "User-agent: *\nDisallow: /\n"

  # Build every cached static asset in one shot. The key naming maps 1:1
  # to the route table in server.cr so adding a new catalog view is a
  # matter of: add a builder above, add an Entry here, add a route in
  # the server table.
  def self.build_all : Hash(String, Entry)
    mazes = Xssmaze.get
    groups = Xssmaze.grouped_mazes
    total = mazes.size

    maze_json_objs = mazes.map(&.to_json_object)
    map_json = {endpoints: maze_json_objs}.to_json
    version = {version: Xssmaze::VERSION, endpoints: total, categories: groups.size}.to_json

    {
      "index"      => Entry.new(build_index_html(groups, total), "text/html; charset=utf-8"),
      "map_text"   => Entry.new(build_map_text(mazes), "text/plain; charset=utf-8"),
      "map_json"   => Entry.new(map_json, "application/json"),
      "map_md"     => Entry.new(build_map_markdown(mazes), "text/markdown; charset=utf-8"),
      "categories" => Entry.new(build_categories_json(groups, total), "application/json"),
      "openapi"    => Entry.new(build_openapi(mazes), "application/json"),
      "sitemap"    => Entry.new(build_sitemap(mazes), "application/xml; charset=utf-8"),
      "version"    => Entry.new(version, "application/json"),
      "stats"      => Entry.new(build_stats(mazes, groups), "application/json"),
      "payloads"   => Entry.new(PAYLOADS_BODY, "application/json"),
      "robots"     => Entry.new(ROBOTS_BODY, "text/plain; charset=utf-8", 3600),
      "css"        => Entry.new(Xssmaze::Assets::INDEX_CSS, "text/css; charset=utf-8", 86400),
      "js"         => Entry.new(Xssmaze::Assets::INDEX_JS, "application/javascript; charset=utf-8", 86400),
    }
  end
end
