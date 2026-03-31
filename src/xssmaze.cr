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

  def self.push(name : String, url : String, desc : String, method : String = "GET", params : Array(String) = ["query"])
    maze = Maze.new(name, url, desc, method, params)
    @@mazes << maze
  end

  def self.get
    @@mazes
  end

  def self.grouped_mazes : Hash(String, Array(Maze))
    groups = Hash(String, Array(Maze)).new
    @@mazes.each do |maze|
      groups[maze.type] ||= [] of Maze
      groups[maze.type] << maze
    end
    groups
  end

  def self.build_maze_list : String
    groups = grouped_mazes
    sorted_types = groups.keys.sort!

    String.build do |io|
      io << "<div class='container'>\n  <ul class='list'>"
      sorted_types.each do |type|
        io << "<li>#{type}"
        io << "<ul class='list'>"
        groups[type].each do |maze|
          io << "<li><a href='#{maze.url}'>#{maze.name}</a> - #{maze.desc}</li>"
        end
        io << "</ul>"
        io << "</li>"
      end
      io << "</ul></div>"
    end
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
      margin: 0 auto 40px;
    }
    h1 {
      color: #333;
      margin-bottom: 10px;
    }
    .description {
      color: #666;
      line-height: 1.6;
      margin-bottom: 10px;
    }
    .description code {
      background-color: #f4f4f4;
      color: #c7254e;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
    }
    .map-links {
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid #e0e0e0;
    }
    .map-links a {
      color: #0366d6;
      text-decoration: none;
      margin-right: 15px;
    }
    .map-links a:hover {
      text-decoration: underline;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 50px 80px;
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
    .list li > .list {
      position: relative;
    }
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
    .list li:last-of-type > .list:after {
      content: none;
    }
    .list li > .list li {
      font-weight: normal;
      font-size: 0.95em;
    }
    .list li > .list li a {
      color: #0366d6;
      text-decoration: none;
    }
    .list li > .list li a:hover {
      text-decoration: underline;
    }
    @media (max-width: 768px) {
      .container {
        padding: 30px 20px;
        margin: 0 10px;
      }
      body {
        padding: 10px;
      }
    }
  CSS

  def self.index_html : String
    maze_list = build_maze_list

    "<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>XSSMaze</title>
  <style>
#{INDEX_CSS}
  </style>
</head>
<body>
  <div class='header'>
    <h1>XSSMaze</h1>
    <p class='description'>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>
    <p class='description'>Most challenges use <code>query</code>, but some cases use parameters such as <code>callback</code>, <code>query2</code>, <code>seed</code>, <code>blob</code>, <code>url</code>, path segments, or request headers.</p>
    <p class='description'>You can find several vulnerable cases in the list below.</p>
    <div class='map-links'>
      <strong>Endpoint Map:</strong>
      <a href='/map/text'>Text</a>
      <a href='/map/json'>JSON</a>
    </div>
  </div>
  #{maze_list}
</body>
</html>"
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

# Index (computed once at startup)
cached_index = Xssmaze.index_html
list = Xssmaze.get

get "/" do
  cached_index
end

get "/map/text" do |env|
  env.response.content_type = "text/plain"
  list.join("\n", &.url)
end

get "/map/json" do |env|
  env.response.content_type = "application/json"
  {endpoints: list.map(&.to_json_object)}.to_json
end

Kemal.run
