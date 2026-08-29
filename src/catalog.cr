require "json"
require "digest/sha1"
require "./solutions"

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

  # Shared <head> for the index and the 404 page so both pick up the same
  # tokens, favicon and pre-paint theme restore.
  private def self.build_head(io : IO, title : String, description : String) : Nil
    io << "<!DOCTYPE html>\n<html lang='en'>\n<head>\n"
    io << "<meta charset='UTF-8'>\n"
    io << "<meta name='viewport' content='width=device-width, initial-scale=1.0'>\n"
    io << "<title>" << title << "</title>\n"
    io << "<meta name='description' content='" << description << "'>\n"
    io << "<meta name='theme-color' content='#ebe8e4' media='(prefers-color-scheme: light)'>\n"
    io << "<meta name='theme-color' content='#100f0e' media='(prefers-color-scheme: dark)'>\n"
    io << "<link rel='icon' href='/favicon.svg' type='image/svg+xml'>\n"
    io << "<link rel='stylesheet' href='/assets/index.css'>\n"
    io << "<script>" << Xssmaze::Assets::THEME_BOOT_JS << "</script>\n"
    io << "</head>\n<body>\n"
  end

  # Endpoints the catalog publishes for tooling. Rendered in the page footer.
  # `/solutions/basic` stands in for the per-category answer key (`/solutions/
  # <category>`); `/solutions.json` is the whole key keyed by maze name.
  MAP_LINKS = %w[
    /map/text /map/json /map/categories /map/markdown /map/openapi
    /solutions.json /solutions/basic
    /stats /payloads /random /health /version
  ]

  def self.build_index_html(groups : Hash(String, Array(Maze)),
                            total : Int32) : String
    maze_list = build_maze_list(groups)
    cat_count = groups.size
    sorted_types = groups.keys.sort!

    # Metadata coverage, straight from the catalog. "unclassified" means not
    # triaged yet, so it is counted as absent rather than as its own class.
    # The per-class breakdown lives in /stats; the header carries the one
    # number that tells a benchmark author how far triage has got.
    classified = 0
    groups.each_value do |type_mazes|
      type_mazes.each { |maze| classified += 1 unless maze.vuln == "unclassified" }
    end

    String.build do |io|
      build_head(io, "XSSMaze",
        "A deliberately vulnerable web service for measuring how well a security " \
        "scanner finds cross-site scripting. #{total} endpoints across #{cat_count} categories.")

      # ----- header -----
      io << "<header class='shell top'>\n<div class='brandline'>\n"
      io << "<div class='brand'>" << Xssmaze::Assets::MARK_SVG << "<div>"
      io << "<h1 class='wordmark'>XSSMaze</h1>"
      io << "<p class='subline'>Cross-site scripting proving ground</p>"
      io << "</div></div>\n"
      io << "<div class='readout'>"
      io << "<div><b>" << total << "</b><span>endpoints</span></div>"
      io << "<div><b>" << cat_count << "</b><span>categories</span></div>"
      io << "<div><b>" << classified << "</b><span>classified</span></div>"
      io << "<div><b>" << Xssmaze::VERSION << "</b><span>version</span></div>"
      io << "</div>\n</div>\n"
      io << "<p class='lede'>A deliberately vulnerable web service for measuring how well a "
      io << "security scanner finds cross-site scripting. Every endpoint carries its own "
      io << "vulnerability class, taint source, and sink.</p>\n"
      io << "<p class='params'>Payloads arrive through "
      io << "<code>query</code><code>callback</code><code>query2</code><code>seed</code>"
      io << "<code>blob</code><code>url</code> plus path segments and request headers.</p>\n"
      io << "</header>\n"

      # ----- control bar -----
      io << "<div class='bar'>\n<div class='bar-in'>\n"
      io << "<input id='search' type='search' aria-label='Filter endpoints' "
      io << "placeholder='filter by name, behaviour, source or sink...  (press /)'>\n"
      io << "<div class='chips' role='group' aria-label='Filter by property'>"
      io << "<button class='chip' data-filter='dom' aria-pressed='false'>dom</button>"
      io << "<button class='chip' data-filter='client' aria-pressed='false'>client-only</button>"
      io << "<button class='chip' data-filter='control' aria-pressed='false'>controls</button>"
      io << "<button class='chip' data-filter='post' aria-pressed='false'>POST/QUERY</button>"
      io << "</div>\n"
      io << "<p class='tally' aria-live='polite'><b id='stat-visible'>" << total
      io << "</b> of " << total << " shown</p>\n"
      io << "<button class='theme' id='theme' aria-label='Switch between light and dark'>&#9681;</button>\n"
      io << "</div>\n</div>\n"

      # ----- corridor list -----
      io << "<div class='shell layout'>\n<nav class='rail-nav' aria-label='Categories'>\n"
      io << "<h2>Categories</h2>\n"
      sorted_types.each do |type|
        io << "<a href='#cat-" << type << "'>" << type
        io << " <i>" << groups[type].size << "</i></a>"
      end
      io << "\n</nav>\n"
      io << maze_list
      io << "</div>\n"

      # ----- footer -----
      io << "<div class='shell'><footer class='foot'><span>Machine-readable</span>"
      MAP_LINKS.each { |path| io << "<a href='" << path << "'>" << path << "</a>" }
      io << "</footer></div>\n"

      io << "<script src='/assets/index.js' defer></script>\n"
      io << "</body>\n</html>"
    end
  end

  # One row per endpoint. `data-hay` is the search haystack (name, description
  # and the DOM taint source/sink names, so typing `innerHTML` or
  # `location.hash` finds the right levels). `data-p` is a space-joined token
  # list the filter chips match against; the JS pads it so a chip matches a
  # whole token rather than a substring.
  private def self.build_maze_list(groups : Hash(String, Array(Maze))) : String
    sorted_types = groups.keys.sort!

    String.build do |io|
      io << "<main id='maze-list'>"
      sorted_types.each do |type|
        type_mazes = groups[type]
        io << "<section class='cat' data-cat='" << type << "' id='cat-" << type << "'>"
        io << "<div class='cat-head'><h2>" << type << "</h2>"
        io << "<span class='count'>" << type_mazes.size << "</span></div>"
        io << "<ul class='rows'>"
        type_mazes.each { |maze| build_maze_row(io, maze) }
        io << "</ul></section>"
      end
      io << "<div class='empty hidden' id='empty'><b>No endpoint matches that.</b>"
      io << "Clear the filter, or try a sink like <code>innerHTML</code>, a source like "
      io << "<code>location.hash</code>, or a level such as <code>level3</code>.</div>"
      io << "</main>"
    end
  end

  private def self.build_maze_row(io : IO, maze : Maze) : Nil
    control = !maze.exploitable?
    client = maze.reach == "client"

    io << "<li class='maze"
    io << " control" if control
    io << "' data-hay='" << Xssmaze.html_escape(maze.name.downcase) << ' '
    io << Xssmaze.html_escape(maze.desc.downcase)
    maze.sources.each { |source| io << ' ' << Xssmaze.html_escape(source.downcase) }
    maze.sinks.each { |sink| io << ' ' << Xssmaze.html_escape(sink.downcase) }
    io << "' data-p='" << maze.vuln
    io << " client" if client
    io << " control" if control
    # The `post` token predates HTTP QUERY and really means "not a plain GET",
    # which is what the POST/QUERY chip filters on. Kept as-is so bookmarked
    # filter state keeps working.
    io << " post" if maze.method != "GET"
    io << "'>"

    io << "<a href='" << maze.url << "'>" << maze.name << "</a>"
    io << "<span class='desc'>" << Xssmaze.html_escape(maze.desc) << "</span>"

    io << "<span class='meta'>"
    io << "<span class='tag cls'>" << maze.vuln << "</span>" unless maze.vuln == "unclassified"
    io << "<span class='tag client'>client</span>" if client
    # The default input is `query`; naming it on every row would be noise, so
    # only a non-default channel (a header, a fragment, a custom param) is shown.
    if (param = maze.params.first?) && param != "query"
      io << "<span class='tag'>" << Xssmaze.html_escape(param) << "</span>"
    end
    io << "<span class='tag method'>" << maze.method << "</span>" if maze.method != "GET"
    io << "</span></li>"
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
      io << "`Class`/`Reach`/`Sources`/`Sinks` are the structured vulnerability\n"
      io << "metadata also served by `/map/json`. `Class` = `non-xss-control` marks a\n"
      io << "deliberate true negative; `Reach` = `client` means the payload only exists\n"
      io << "browser-side (fragment, postMessage, clipboard, ...) and cannot be delivered\n"
      io << "by a request-only scanner.\n\n"
      io << "| Name | Method | URL | Params | Class | Reach | Sources | Sinks | Description |\n"
      io << "|------|--------|-----|--------|-------|-------|---------|-------|-------------|\n"
      mazes.each do |maze|
        io << "| " << maze.name
        io << " | " << maze.method
        io << " | `" << maze.url << "`"
        io << " | `" << maze.params.join(",") << "`"
        io << " | " << maze.vuln
        io << " | " << maze.reach
        io << " | " << md_cell(maze.sources)
        io << " | " << md_cell(maze.sinks)
        io << " | " << maze.desc.gsub("|", "\\|")
        io << " |\n"
      end
    end
  end

  private def self.md_cell(values : Array(String)) : String
    return "-" if values.empty?
    values.map { |v| "`#{v}`" }.join(" ")
  end

  # Per-category rollup. Beyond the raw count, this breaks each category down
  # by vulnerability class and reachability so a benchmark can pick its target
  # set (and exclude controls) without walking every endpoint in /map/json.
  def self.build_categories_json(groups : Hash(String, Array(Maze)),
                                 total : Int32) : String
    arr = groups.keys.sort!.map do |cat|
      cat_mazes = groups[cat]
      classes = Hash(String, Int32).new(0)
      reaches = Hash(String, Int32).new(0)
      cat_mazes.each do |maze|
        classes[maze.vuln] += 1
        reaches[maze.reach] += 1
      end
      {
        category:    cat,
        count:       cat_mazes.size,
        exploitable: cat_mazes.count(&.exploitable?),
        controls:    cat_mazes.count { |maze| !maze.exploitable? },
        classes:     classes,
        reach:       reaches,
      }
    end
    {total: total, categories: arr}.to_json
  end

  # Path Item operations OpenAPI 3.0 actually defines. Anything outside this
  # set — HTTP QUERY, for one — is not a valid Path Item field, so it goes
  # into the `x-additional-operations` extension instead of quietly making the
  # whole document invalid for every consumer.
  OPENAPI_METHODS = %w[get put post delete options head patch trace]

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
      if OPENAPI_METHODS.includes?(method)
        paths[path][method] = op
      else
        extra = paths[path]["x-additional-operations"]? || {} of String => JSON::Any
        extra[maze.method] = JSON.parse(op.to_json)
        paths[path]["x-additional-operations"] = extra
      end
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
    classes_count = Hash(String, Int32).new(0)
    reach_count = Hash(String, Int32).new(0)
    sources_count = Hash(String, Int32).new(0)
    sinks_count = Hash(String, Int32).new(0)
    mazes.each do |maze|
      methods_count[maze.method] += 1
      maze.params.each { |param| params_count[param] += 1 }
      classes_count[maze.vuln] += 1
      reach_count[maze.reach] += 1
      maze.sources.each { |source| sources_count[source] += 1 }
      maze.sinks.each { |sink| sinks_count[sink] += 1 }
    end
    {
      total:       mazes.size,
      categories:  groups.size,
      methods:     methods_count,
      params:      params_count.to_a.sort_by! { |(_, v)| -v }.to_h,
      classes:     classes_count.to_a.sort_by! { |(_, v)| -v }.to_h,
      reach:       reach_count,
      exploitable: mazes.count(&.exploitable?),
      controls:    mazes.count { |maze| !maze.exploitable? },
      sources:     sources_count.to_a.sort_by! { |(_, v)| -v }.to_h,
      sinks:       sinks_count.to_a.sort_by! { |(_, v)| -v }.to_h,
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

  # The 404 body is the one page that varies per request (it echoes the
  # missed path), so it is rendered rather than cached like the entries
  # above. The path is escaped — this page is chrome, not a maze. It shares
  # the index stylesheet instead of carrying its own, so the two pages can
  # never drift apart.
  def self.render_404(path : String) : String
    String.build do |io|
      build_head(io, "404 - XSSMaze", "No maze at that path.")
      io << "<div class='shell'><div class='notfound'>"
      io << "<h1>404</h1>"
      io << "<p>No maze at <span class='path'>" << Xssmaze.html_escape(path) << "</span>.</p>"
      io << "<p>Try the <a href='/'>index</a>, the <a href='/map/text'>text map</a>, "
      io << "the <a href='/map/categories'>category list</a>, or "
      io << "<a href='/random'>a random maze</a>.</p>"
      io << "</div></div></body></html>"
    end
  end

  # One cached Entry per solution category, keyed by category name. Built the
  # same way as the flat catalog views so `/solutions/<category>` gets the same
  # ETag / gzip / 304 treatment — it just needs a dynamic route to select the
  # category rather than a fixed STATIC_ROUTES row.
  def self.build_solution_pages : Hash(String, Entry)
    pages = Hash(String, Entry).new
    Xssmaze::Solutions.categories.each do |category|
      body = Xssmaze::Solutions.markdown(category) || ""
      pages[category] = Entry.new(body, "text/markdown; charset=utf-8")
    end
    pages
  end

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
      "index"          => Entry.new(build_index_html(groups, total), "text/html; charset=utf-8"),
      "map_text"       => Entry.new(build_map_text(mazes), "text/plain; charset=utf-8"),
      "map_json"       => Entry.new(map_json, "application/json"),
      "map_md"         => Entry.new(build_map_markdown(mazes), "text/markdown; charset=utf-8"),
      "solutions_json" => Entry.new(Xssmaze::Solutions.json_body, "application/json"),
      "categories"     => Entry.new(build_categories_json(groups, total), "application/json"),
      "openapi"        => Entry.new(build_openapi(mazes), "application/json"),
      "sitemap"        => Entry.new(build_sitemap(mazes), "application/xml; charset=utf-8"),
      "version"        => Entry.new(version, "application/json"),
      "stats"          => Entry.new(build_stats(mazes, groups), "application/json"),
      "payloads"       => Entry.new(PAYLOADS_BODY, "application/json"),
      "robots"         => Entry.new(ROBOTS_BODY, "text/plain; charset=utf-8", 3600),
      "css"            => Entry.new(Xssmaze::Assets::INDEX_CSS, "text/css; charset=utf-8", 86400),
      "js"             => Entry.new(Xssmaze::Assets::INDEX_JS, "application/javascript; charset=utf-8", 86400),
      "favicon"        => Entry.new(Xssmaze::Assets::FAVICON_SVG, "image/svg+xml; charset=utf-8", 86400),
    }
  end
end
