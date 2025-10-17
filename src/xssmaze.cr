require "kemal"
require "./maze"
require "./mazes/**"
require "./banner"

module Xssmaze
  VERSION = "0.1.0"
  @@mazes = [] of Maze

  def self.push(name : String, url : String, desc : String)
    maze = Maze.new(name, url, desc)
    @@mazes << maze
  end

  def self.get
    @@mazes
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

# Index
list = Xssmaze.get

# Group mazes by type
grouped_mazes = Hash(String, Array(Maze)).new

list.each do |obj|
  # Extract type from name (e.g., "basic-level1" -> "basic")
  parts = obj.name.split("-")
  type = parts.size > 0 ? parts[0] : "other"
  grouped_mazes[type] ||= [] of Maze
  grouped_mazes[type] << obj
end

# Sort types alphabetically
sorted_types = grouped_mazes.keys.sort

# Build hierarchical HTML
indexdata = "<div class='container'>
  <ul class='list'>"

sorted_types.each do |type|
  indexdata += "<li>#{type}"
  
  mazes = grouped_mazes[type]
  indexdata += "<ul class='list'>"
  mazes.each do |maze|
    indexdata += "<li><a href='#{maze.url}'>#{maze.name}</a> - #{maze.desc}</li>"
  end
  indexdata += "</ul>"
  
  indexdata += "</li>"
end

indexdata += "</ul></div>"

get "/" do
  "<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>XSSMaze</title>
  <style>
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
  </style>
</head>
<body>
  <div class='header'>
    <h1>XSSMaze</h1>
    <p class='description'>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>
    <p class='description'>All vulnerable parameters are named <code>query</code>.</p>
    <p class='description'>You can find several vulnerable cases in the list below.</p>
    <div class='map-links'>
      <strong>Endpoint Map:</strong>
      <a href='/map/text'>Text</a>
      <a href='/map/json'>JSON</a>
    </div>
  </div>
  #{indexdata}
</body>
</html>"
end

get "/map/text" do |env|
  env.response.content_type = "text/plain"
  tmp = ""
  list.each do |obj|
    tmp += "#{obj.url}\n"
  end

  tmp
end

get "/map/json" do |env|
  env.response.content_type = "application/json"
  tmp = "{\"endpoints\": ["
  list.each do |obj|
    tmp += "\"#{obj.url}\","
  end
  tmp = tmp[0...-1] + "]}"

  tmp
end

Kemal.run
