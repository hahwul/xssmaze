require "json"
require "compress/gzip"
require "digest/sha1"
require "kemal"
require "./filters"
require "./route_helper"
require "./maze"
require "./mazes/**"
require "./banner"

module Xssmaze
  VERSION = "0.1.0"
  @@mazes = [] of Maze
  @@frozen = false

  def self.push(name : String, url : String, desc : String, method : String = "GET", params : Array(String) = ["query"])
    raise "maze list is frozen" if @@frozen
    maze = Maze.new(name, url, desc, method, params)
    @@mazes << maze
  end

  def self.get
    @@mazes
  end

  def self.freeze!
    @@frozen = true
    @@mazes.sort_by!(&.name)
  end

  def self.grouped_mazes : Hash(String, Array(Maze))
    groups = Hash(String, Array(Maze)).new
    @@mazes.each do |maze|
      groups[maze.type] ||= [] of Maze
      groups[maze.type] << maze
    end
    groups
  end

  def self.build_maze_list(groups : Hash(String, Array(Maze))) : String
    sorted_types = groups.keys.sort

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
          io << "' data-desc='" << html_escape(maze.desc.downcase) << "'>"
          io << "<a href='" << maze.url << "'>" << maze.name << "</a>"
          io << " <span class='method'>" << maze.method << "</span>"
          io << " - " << html_escape(maze.desc) << "</li>"
        end
        io << "</ul></li>"
      end
      io << "</ul></div>"
    end
  end

  def self.html_escape(s : String) : String
    s.gsub('&', "&amp;").gsub('<', "&lt;").gsub('>', "&gt;").gsub('"', "&quot;").gsub('\'', "&#39;")
  end

  INDEX_CSS = <<-CSS
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #ffffff;
    }
    .header {
      max-width: 1200px;
      margin: 0 auto 20px;
    }
    h1 { color: #333; margin-bottom: 10px; }
    .description { color: #666; line-height: 1.6; margin-bottom: 10px; }
    .description code {
      background-color: #f4f4f4;
      color: #c7254e;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
    }
    .stats {
      display: flex;
      gap: 18px;
      margin: 14px 0;
      flex-wrap: wrap;
    }
    .stats .stat {
      background: #f5f5f5;
      padding: 6px 12px;
      border-radius: 4px;
      font-size: 0.9em;
      color: #333;
    }
    .stats .stat strong { color: #0366d6; }
    .controls {
      display: flex;
      gap: 10px;
      margin-top: 16px;
      align-items: center;
      flex-wrap: wrap;
    }
    #search {
      flex: 1;
      min-width: 240px;
      padding: 8px 12px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 14px;
    }
    .map-links {
      margin-top: 14px;
      padding-top: 14px;
      border-top: 1px solid #e0e0e0;
      font-size: 0.92em;
    }
    .map-links a {
      color: #0366d6;
      text-decoration: none;
      margin-right: 12px;
    }
    .map-links a:hover { text-decoration: underline; }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 30px 60px;
      background-color: #F5F5F5;
      border-radius: 8px;
    }
    .list {
      list-style: none;
      padding: 0;
      margin: 0;
      line-height: 1.1;
    }
    .list li {
      padding: 0.2em 0 0.2em 1.2em;
      margin: 0;
      position: relative;
      font-weight: 600;
      color: #333;
    }
    .list li:before {
      content: '';
      width: 0.5em;
      height: 0.5em;
      position: absolute;
      border-radius: 0.5em;
      background-color: #666;
      display: block;
      left: -0.2em;
      top: 0.4em;
    }
    .list li + li:after {
      content: '';
      display: block;
      width: 2px;
      height: 1em;
      padding: 0.2em 0;
      background-color: #666;
      position: absolute;
      left: 0;
      top: -0.75em;
    }
    .list li > .list { position: relative; }
    .list li > .list:before {
      content: '';
      display: block;
      width: 1.5em;
      height: 2px;
      background-color: #666;
      position: absolute;
      left: -1.35em;
      top: -0.1em;
      transform: rotate(45deg);
    }
    .list li > .list:after {
      content: '';
      display: block;
      width: 2px;
      height: 115%;
      background-color: #666;
      position: absolute;
      left: -1.2em;
      top: -0.5em;
    }
    .list li:last-of-type > .list:after { content: none; }
    .list li > .list li {
      font-weight: normal;
      font-size: 0.95em;
    }
    .list li > .list li a {
      color: #0366d6;
      text-decoration: none;
    }
    .list li > .list li a:hover { text-decoration: underline; }
    .count {
      color: #888;
      font-weight: normal;
      font-size: 0.85em;
    }
    .method {
      display: inline-block;
      font-size: 0.7em;
      font-weight: 700;
      color: #666;
      background: #e7e7e7;
      padding: 1px 6px;
      border-radius: 3px;
      margin-left: 4px;
    }
    .hidden { display: none !important; }
    @media (max-width: 768px) {
      .container { padding: 20px 16px; margin: 0 8px; }
      body { padding: 10px; }
    }
  CSS

  INDEX_JS = <<-JS
    (function () {
      var input = document.getElementById('search');
      if (!input) return;
      var mazes = document.querySelectorAll('.maze');
      var cats = document.querySelectorAll('.cat');
      var totalEl = document.getElementById('stat-visible');
      input.addEventListener('input', function () {
        var q = input.value.toLowerCase().trim();
        var visible = 0;
        mazes.forEach(function (el) {
          var name = el.getAttribute('data-name') || '';
          var desc = el.getAttribute('data-desc') || '';
          var match = q === '' || name.indexOf(q) !== -1 || desc.indexOf(q) !== -1;
          el.classList.toggle('hidden', !match);
          if (match) visible++;
        });
        cats.forEach(function (cat) {
          var any = cat.querySelectorAll('.maze:not(.hidden)').length > 0;
          cat.classList.toggle('hidden', !any);
        });
        if (totalEl) totalEl.textContent = visible;
      });
    })();
  JS

  def self.build_index_html(groups : Hash(String, Array(Maze))) : String
    maze_list = build_maze_list(groups)
    total = @@mazes.size
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
      io << "<span class='stat'>v" << VERSION << "</span>\n"
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

  def self.build_map_text(mazes : Array(Maze)) : String
    String.build do |io|
      mazes.each_with_index do |m, i|
        io << '\n' if i > 0
        io << m.url
      end
    end
  end

  def self.build_map_markdown(mazes : Array(Maze)) : String
    String.build do |io|
      io << "# XSSMaze Endpoints\n\n"
      io << "Total: " << mazes.size << "\n\n"
      io << "| Name | Method | URL | Params | Description |\n"
      io << "|------|--------|-----|--------|-------------|\n"
      mazes.each do |m|
        io << "| " << m.name
        io << " | " << m.method
        io << " | `" << m.url << "`"
        io << " | `" << m.params.join(",") << "`"
        io << " | " << m.desc.gsub("|", "\\|")
        io << " |\n"
      end
    end
  end

  def self.build_categories_json(groups : Hash(String, Array(Maze))) : String
    arr = groups.keys.sort.map do |cat|
      {category: cat, count: groups[cat].size}
    end
    {total: @@mazes.size, categories: arr}.to_json
  end

  # Minimal OpenAPI 3.0 document so external tooling (Swagger UI, code
  # generators, scanner runners) can ingest the catalog directly.
  def self.build_openapi(mazes : Array(Maze)) : String
    paths = Hash(String, Hash(String, Hash(String, JSON::Any))).new
    mazes.each do |m|
      # Strip query string from URL when keying paths.
      path = m.url.split("?", 2).first
      method = m.method.downcase
      params_arr = m.params.map do |p|
        loc = case p
              when ":path" then "path"
              when "Cookie", "Referer", "User-Agent", "Authorization"
                "header"
              else
                "query"
              end
        JSON.parse({name: p, in: loc, required: false, description: "maze input", schema: {type: "string"}}.to_json)
      end
      op = {
        "summary"     => JSON.parse(m.name.to_json),
        "description" => JSON.parse(m.desc.to_json),
        "tags"        => JSON.parse([m.type].to_json),
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
        version:     VERSION,
        description: "Intentionally vulnerable XSS lab. Endpoints are reflective by design.",
      },
      paths: paths,
    }.to_json
  end

  def self.build_sitemap(mazes : Array(Maze)) : String
    String.build do |io|
      io << %(<?xml version="1.0" encoding="UTF-8"?>\n)
      io << %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
      mazes.each do |m|
        path = m.url.split("?", 2).first
        io << "  <url><loc>" << path << "</loc></url>\n"
      end
      io << "</urlset>\n"
    end
  end

  def self.gzip(body : String) : Bytes
    io = IO::Memory.new
    Compress::Gzip::Writer.open(io, level: Compress::Gzip::BEST_COMPRESSION) do |gz|
      gz.write(body.to_slice)
    end
    io.to_slice.dup
  end
end

banner

# Routes
load_basic
load_dom
load_header
load_path
load_post
load_redirect
load_decode
load_hidden_xss
load_injs_xss
load_inframe_xss
load_inattr_xss
load_jf_xss
load_eventhandler_xss
load_csp_bypass
load_svg_xss
load_css_injection
load_template_injection
load_websocket_xss
load_json_xss
load_advanced_xss
load_polyglot_xss
load_browser_state_xss
load_opener_xss
load_storage_event_xss
load_stream_xss
load_channel_xss
load_service_worker_xss
load_history_state_xss
load_reparse_xss
load_referrer_xss
load_prototype_pollution_xss
load_mxss
load_stored_xss
load_shadow_dom_xss
load_csti_xss
load_import_map_xss
load_realworld
load_realworld_encoding
load_realworld_input
load_multi_context_xss
load_encoding_bypass_xss
load_special_tag_xss
load_filter_chain_xss
load_context_escape_xss
load_waf_bypass_xss
load_sink_xss
load_param_pollution_xss
load_edge_case_xss
load_modern_framework_xss
load_response_split_xss
load_sanitizer_bypass_xss
load_callback_xss
load_mutation_filter_xss
load_race_condition_xss
load_unicode_xss
load_timing_xss
load_double_encoding_xss
load_nonce_bypass_xss
load_content_type_xss
load_multipart_xss
load_recursive_filter_xss
load_parser_differential_xss
load_chained_filter_xss
load_template_injection_xss
load_encoding_mix_xss
load_waf_bypass_v2_xss
load_context_escape_v2_xss
load_fragment_xss
load_header_injection_xss
load_js_context_xss
load_attribute_context_xss
load_post_method_xss
load_redirect_xss
load_svg_context_xss
load_obfuscation_xss
load_multi_param_xss
load_truncation_xss
load_comment_injection_xss
load_nested_context_xss
load_csp_bypass_xss
load_dom_context_xss
load_edge_filter_xss
load_polyglot_context_xss
load_whitespace_xss
load_double_reflection_xss
load_case_manipulation_xss
load_json_context_xss
load_error_page_xss
load_partial_encode_xss
load_data_attribute_xss
load_mixed_method_xss
load_table_context_xss
load_media_context_xss
load_special_char_xss
load_semantic_tag_xss
load_form_element_xss
load_link_context_xss
load_xml_context_xss
load_regex_filter_xss
load_path_based_xss
load_char_limit_filter_xss
load_multiline_xss
load_response_header_xss
load_replacement_filter_xss
load_input_transform_xss
load_multiple_output_xss
load_conditional_reflect_xss
load_nested_filter_xss
load_real_world_pattern_xss
load_wrapper_context_xss
load_complex_page_xss
load_tag_attribute_mix_xss
load_script_gadget_xss
load_encoding_edge_xss
load_multi_vector_xss
load_sanitizer_edge_xss
load_hidden_reflection_xss
load_prototype_xss
load_framework_output_xss
load_payload_filter_xss
load_late_reflection_xss
load_api_response_xss
load_attribute_event_xss
load_url_param_context_xss
load_seo_context_xss
load_js_string_escape_xss
load_custom_tag_xss
load_embed_context_xss
load_global_attr_xss
load_error_handling_xss
load_aria_attr_xss
load_microdata_xss
load_inline_style_xss
load_numeric_context_xss
load_boolean_attr_xss
load_list_iteration_xss
load_cms_pattern_xss
load_ecommerce_xss
load_dashboard_xss
load_email_template_xss
load_social_media_xss
load_misc_context_xss
load_dialog_xss
load_meta_refresh_xss
load_trusted_types_xss
load_iframe_srcdoc_xss
load_mathml_xss
load_popover_xss
load_clipboard_xss
load_dragdrop_xss
load_worker_xss
load_formaction_xss
load_srcset_xss
load_dataurl_xss
load_manifest_xss
load_template_tag_xss
load_noscript_xss
load_slot_xss
load_mutation_observer_xss
load_attrname_xss
load_bugbounty_pattern_xss
load_markdown_render_xss
load_bounty_scanner_xss
load_regex_bypass_xss
load_multi_reflection_xss
load_stored_pattern_xss

# Freeze maze list and pre-compute caches once at startup so /map/* and /
# never rebuild HTML/JSON/text on the request hot path. Using locals (not
# top-level constants) because Crystal forbids constants from referencing
# locals; Kemal's blocks close over these just fine.
Xssmaze.freeze!
mazes = Xssmaze.get
groups = Xssmaze.grouped_mazes

cached_index = Xssmaze.build_index_html(groups)
cached_map_text = Xssmaze.build_map_text(mazes)
# Materialize maze JSON objects once; reuse for both the unfiltered cache
# and any filtered request so /map/json never rebuilds the per-maze tuples.
mazes_json_objs = mazes.map(&.to_json_object)
cached_map_json = {endpoints: mazes_json_objs}.to_json
cached_map_md = Xssmaze.build_map_markdown(mazes)
cached_categories = Xssmaze.build_categories_json(groups)
cached_openapi = Xssmaze.build_openapi(mazes)
cached_sitemap = Xssmaze.build_sitemap(mazes)
cached_version = {version: Xssmaze::VERSION, endpoints: mazes.size, categories: groups.size}.to_json

# Distribution stats (counts by HTTP method and by primary param).
methods_count = Hash(String, Int32).new(0)
params_count = Hash(String, Int32).new(0)
mazes.each do |m|
  methods_count[m.method] += 1
  m.params.each { |p| params_count[p] += 1 }
end
cached_stats = {
  total:      mazes.size,
  categories: groups.size,
  methods:    methods_count,
  params:     params_count.to_a.sort_by! { |(_, v)| -v }.to_h,
}.to_json

cached_payloads = {
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

# CSS / JS extracted as their own assets so the browser can cache them
# separately from the (changes-on-startup) catalog HTML.
css_body = Xssmaze::INDEX_CSS
js_body = Xssmaze::INDEX_JS

robots_body = "User-agent: *\nDisallow: /\n"

# ETag is just a content hash. Catalog payloads are content-stable for the
# lifetime of the process so we can compute it once.
def make_etag(body : String) : String
  %("#{Digest::SHA1.hexdigest(body)[0, 16]}")
end

etag_index = make_etag(cached_index)
etag_map_text = make_etag(cached_map_text)
etag_map_json = make_etag(cached_map_json)
etag_map_md = make_etag(cached_map_md)
etag_categories = make_etag(cached_categories)
etag_openapi = make_etag(cached_openapi)
etag_sitemap = make_etag(cached_sitemap)
etag_version = make_etag(cached_version)
etag_stats = make_etag(cached_stats)
etag_payloads = make_etag(cached_payloads)
etag_css = make_etag(css_body)
etag_js = make_etag(js_body)
etag_robots = make_etag(robots_body)

# Pre-compress all catalog payloads once at startup. Compressed at level 9
# because the work happens exactly once and the bandwidth savings on the
# 200KB+ index pay for themselves immediately.
gz_index = Xssmaze.gzip(cached_index)
gz_map_text = Xssmaze.gzip(cached_map_text)
gz_map_json = Xssmaze.gzip(cached_map_json)
gz_map_md = Xssmaze.gzip(cached_map_md)
gz_categories = Xssmaze.gzip(cached_categories)
gz_openapi = Xssmaze.gzip(cached_openapi)
gz_sitemap = Xssmaze.gzip(cached_sitemap)
gz_version = Xssmaze.gzip(cached_version)
gz_stats = Xssmaze.gzip(cached_stats)
gz_payloads = Xssmaze.gzip(cached_payloads)
gz_css = Xssmaze.gzip(css_body)
gz_js = Xssmaze.gzip(js_body)

# Tighten Kemal defaults before any CLI parsing or server startup.
#
# 1. Kemal's built-in default binds to 0.0.0.0, which would expose this
#    intentionally-vulnerable lab to the whole local network. Default to
#    loopback; users who want network exposure (e.g. Docker port mapping)
#    pass `-b 0.0.0.0` explicitly.
# 2. Kemal's default env is "development", which makes the exception
#    handler render verbose 500 pages with stack traces and source
#    snippets. Every maze reflects user input, so any unexpected error
#    during fuzzing would leak server source. Force production unless
#    KEMAL_ENV is explicitly set.
Kemal.config.host_binding = "127.0.0.1"
Kemal.config.env = "production" unless ENV["KEMAL_ENV"]?

start_time = Time.utc
server_header = "XSSMaze/#{Xssmaze::VERSION}"
last_modified = HTTP.format_time(start_time)

before_all do |env|
  env.response.headers["Server"] = server_header
end

# Add a few helpful headers (CORS for tooling; simple Cache-Control for the
# static catalog). The maze endpoints themselves are intentionally untouched.
def with_catalog_headers(env)
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Cache-Control"] = "public, max-age=60"
  env.response.headers["Vary"] = "Accept-Encoding"
end

# Serve a cached payload with conditional GET (ETag/304) and gzip support.
# Returns "" when the response has already been written (304 or gzip path).
def serve_cached(env, body : String, body_gz : Bytes, content_type : String,
                 etag : String, last_modified : String, max_age : Int32 = 60)
  env.response.content_type = content_type
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Cache-Control"] = "public, max-age=#{max_age}"
  env.response.headers["Vary"] = "Accept-Encoding"
  env.response.headers["ETag"] = etag
  env.response.headers["Last-Modified"] = last_modified

  if (inm = env.request.headers["If-None-Match"]?) && inm == etag
    env.response.status_code = 304
    return ""
  end

  ae = env.request.headers["Accept-Encoding"]?
  if ae && ae.includes?("gzip")
    env.response.headers["Content-Encoding"] = "gzip"
    env.response.write(body_gz)
    ""
  else
    body
  end
end

get "/" do |env|
  serve_cached(env, cached_index, gz_index, "text/html; charset=utf-8", etag_index, last_modified)
end

get "/health" do |env|
  env.response.content_type = "application/json"
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Cache-Control"] = "no-store"
  uptime = (Time.utc - start_time).total_seconds.to_i
  {status: "ok", uptime_seconds: uptime, endpoints: mazes.size}.to_json
end

# k8s-style alias.
get "/healthz" do |env|
  env.response.content_type = "application/json"
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Cache-Control"] = "no-store"
  uptime = (Time.utc - start_time).total_seconds.to_i
  {status: "ok", uptime_seconds: uptime, endpoints: mazes.size}.to_json
end

get "/version" do |env|
  serve_cached(env, cached_version, gz_version, "application/json", etag_version, last_modified)
end

get "/stats" do |env|
  serve_cached(env, cached_stats, gz_stats, "application/json", etag_stats, last_modified)
end

get "/payloads" do |env|
  serve_cached(env, cached_payloads, gz_payloads, "application/json", etag_payloads, last_modified)
end

get "/robots.txt" do |env|
  serve_cached(env, robots_body, Xssmaze.gzip(robots_body), "text/plain; charset=utf-8", etag_robots, last_modified, 3600)
end

get "/map/text" do |env|
  serve_cached(env, cached_map_text, gz_map_text, "text/plain; charset=utf-8", etag_map_text, last_modified)
end

get "/map/json" do |env|
  type = env.params.query["type"]?
  q = env.params.query["q"]?
  if type.nil? && q.nil?
    next serve_cached(env, cached_map_json, gz_map_json, "application/json", etag_map_json, last_modified)
  end
  # Filter the pre-materialized JSON objects rather than rebuilding tuples.
  with_catalog_headers(env)
  env.response.content_type = "application/json"
  filtered_idx = (0...mazes.size).to_a
  if t = type
    filtered_idx = filtered_idx.select { |i| mazes[i].type == t }
  end
  if needle = q
    n = needle.downcase
    filtered_idx = filtered_idx.select do |i|
      m = mazes[i]
      m.name.downcase.includes?(n) || m.desc.downcase.includes?(n)
    end
  end
  filtered_objs = filtered_idx.map { |i| mazes_json_objs[i] }
  {endpoints: filtered_objs, total: filtered_objs.size}.to_json
end

get "/map/markdown" do |env|
  serve_cached(env, cached_map_md, gz_map_md, "text/markdown; charset=utf-8", etag_map_md, last_modified)
end

get "/map/categories" do |env|
  serve_cached(env, cached_categories, gz_categories, "application/json", etag_categories, last_modified)
end

get "/map/openapi" do |env|
  serve_cached(env, cached_openapi, gz_openapi, "application/json", etag_openapi, last_modified)
end

get "/sitemap.xml" do |env|
  serve_cached(env, cached_sitemap, gz_sitemap, "application/xml; charset=utf-8", etag_sitemap, last_modified)
end

get "/assets/index.css" do |env|
  serve_cached(env, css_body, gz_css, "text/css; charset=utf-8", etag_css, last_modified, 86400)
end

get "/assets/index.js" do |env|
  serve_cached(env, js_body, gz_js, "application/javascript; charset=utf-8", etag_js, last_modified, 86400)
end

# Pick a random maze and 302 to it. Useful for lab demos and fuzzers that
# want to rotate targets without parsing the catalog.
get "/random" do |env|
  pick = mazes.sample
  env.response.headers["Cache-Control"] = "no-store"
  env.redirect pick.url
end

# 404 — keep response body small and helpful for lab users hitting wrong paths.
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

Kemal.run
