require "kemal"
require "./maze"
require "./mazes/**"
require "./banner"

module Xssmaze
  VERSION = "0.1.0"
  @@mazes = [] of Maze

  def self.push(name : String, url : String, desc : String, category : String = "")
    maze = Maze.new(name, url, desc, category)
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

# Group mazes by category
grouped_mazes = {} of String => Array(Maze)
list.each do |maze|
  category = maze.category.empty? ? maze.name.split("-")[0] : maze.category
  grouped_mazes[category] ||= [] of Maze
  grouped_mazes[category] << maze
end

# Sort categories alphabetically
sorted_categories = grouped_mazes.keys.sort

indexdata = ""
sorted_categories.each do |category|
  indexdata += "<div class='category'>"
  indexdata += "<h2>#{category.capitalize.gsub("-", " ").gsub("_", " ")}</h2>"
  indexdata += "<ul>"
  grouped_mazes[category].each do |obj|
    indexdata += "<li><a href='#{obj.url}'>#{obj.name}</a> <span class='desc'>#{obj.desc}</span></li>"
  end
  indexdata += "</ul>"
  indexdata += "</div>"
end

get "/" do
  "<!DOCTYPE html>
  <html>
  <head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>XSSMaze</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 20px;
      }
      
      .container {
        max-width: 1200px;
        margin: 0 auto;
        background: white;
        border-radius: 10px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        overflow: hidden;
      }
      
      header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 40px;
        text-align: center;
      }
      
      header h1 {
        font-size: 3em;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
      }
      
      header p {
        font-size: 1.1em;
        opacity: 0.9;
        margin-bottom: 10px;
      }
      
      .query-param {
        display: inline-block;
        background: rgba(255,255,255,0.2);
        padding: 5px 15px;
        border-radius: 20px;
        font-weight: bold;
        margin-top: 10px;
      }
      
      .nav-links {
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid rgba(255,255,255,0.3);
      }
      
      .nav-links a {
        color: white;
        text-decoration: none;
        padding: 8px 20px;
        background: rgba(255,255,255,0.2);
        border-radius: 5px;
        margin: 0 5px;
        display: inline-block;
        transition: background 0.3s;
      }
      
      .nav-links a:hover {
        background: rgba(255,255,255,0.3);
      }
      
      .content {
        padding: 40px;
      }
      
      .category {
        margin-bottom: 40px;
        border-left: 4px solid #667eea;
        padding-left: 20px;
      }
      
      .category h2 {
        color: #667eea;
        font-size: 1.8em;
        margin-bottom: 15px;
        text-transform: capitalize;
      }
      
      .category ul {
        list-style: none;
      }
      
      .category li {
        padding: 12px 0;
        border-bottom: 1px solid #eee;
        transition: background 0.2s;
      }
      
      .category li:hover {
        background: #f8f9fa;
        padding-left: 10px;
      }
      
      .category li:last-child {
        border-bottom: none;
      }
      
      .category li a {
        color: #667eea;
        text-decoration: none;
        font-weight: 600;
        font-size: 1.05em;
      }
      
      .category li a:hover {
        text-decoration: underline;
      }
      
      .desc {
        color: #666;
        font-size: 0.95em;
        margin-left: 10px;
      }
      
      footer {
        background: #f8f9fa;
        padding: 20px;
        text-align: center;
        color: #666;
        font-size: 0.9em;
      }
      
      @media (max-width: 768px) {
        header h1 {
          font-size: 2em;
        }
        
        .content {
          padding: 20px;
        }
        
        .category {
          padding-left: 10px;
        }
      }
    </style>
  </head>
  <body>
    <div class='container'>
      <header>
        <h1>🎯 XSSMaze</h1>
        <p>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>
        <p>All vulnerable parameters are named <span class='query-param'>query</span>.</p>
        <div class='nav-links'>
          <span>Endpoint Map:</span>
          <a href='/map/text'>📄 Text</a>
          <a href='/map/json'>📋 JSON</a>
        </div>
      </header>
      <div class='content'>
        " + indexdata + "
      </div>
      <footer>
        XSSMaze - Educational XSS Vulnerability Testing Platform
      </footer>
    </div>
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
