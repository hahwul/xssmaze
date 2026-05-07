require "json"
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
      io << "<title>XSSMaze</title>\n<style>\n"
      io << INDEX_CSS
      io << "\n</style>\n</head>\n<body>\n"
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
      io << "\n<script>\n" << INDEX_JS << "\n</script>\n"
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

# Freeze maze list and pre-compute caches once at startup so /map/* and /
# never rebuild HTML/JSON/text on the request hot path. Using locals (not
# top-level constants) because Crystal forbids constants from referencing
# locals; Kemal's blocks close over these just fine.
Xssmaze.freeze!
mazes = Xssmaze.get
groups = Xssmaze.grouped_mazes

cached_index = Xssmaze.build_index_html(groups)
cached_map_text = Xssmaze.build_map_text(mazes)
cached_map_json = {endpoints: mazes.map(&.to_json_object)}.to_json
cached_map_md = Xssmaze.build_map_markdown(mazes)
cached_categories = Xssmaze.build_categories_json(groups)
cached_version = {version: Xssmaze::VERSION, endpoints: mazes.size, categories: groups.size}.to_json

start_time = Time.utc

# Add a few helpful headers (CORS for tooling; simple Cache-Control for the
# static catalog). The maze endpoints themselves are intentionally untouched.
def with_catalog_headers(env)
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Cache-Control"] = "public, max-age=60"
end

get "/" do |env|
  env.response.content_type = "text/html; charset=utf-8"
  env.response.headers["Cache-Control"] = "public, max-age=60"
  cached_index
end

get "/health" do |env|
  env.response.content_type = "application/json"
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  uptime = (Time.utc - start_time).total_seconds.to_i
  {status: "ok", uptime_seconds: uptime, endpoints: mazes.size}.to_json
end

get "/version" do |env|
  env.response.content_type = "application/json"
  with_catalog_headers(env)
  cached_version
end

get "/map/text" do |env|
  env.response.content_type = "text/plain; charset=utf-8"
  with_catalog_headers(env)
  cached_map_text
end

get "/map/json" do |env|
  env.response.content_type = "application/json"
  with_catalog_headers(env)
  type = env.params.query["type"]?
  q = env.params.query["q"]?
  if type.nil? && q.nil?
    next cached_map_json
  end
  filtered = mazes
  if t = type
    filtered = filtered.select { |m| m.type == t }
  end
  if needle = q
    n = needle.downcase
    filtered = filtered.select { |m| m.name.downcase.includes?(n) || m.desc.downcase.includes?(n) }
  end
  {endpoints: filtered.map(&.to_json_object), total: filtered.size}.to_json
end

get "/map/markdown" do |env|
  env.response.content_type = "text/markdown; charset=utf-8"
  with_catalog_headers(env)
  cached_map_md
end

get "/map/categories" do |env|
  env.response.content_type = "application/json"
  with_catalog_headers(env)
  cached_categories
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
