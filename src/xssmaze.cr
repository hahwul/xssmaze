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

# Index
list = Xssmaze.get
indexdata = "<ul>"

list.each do |obj|
  indexdata += "<li><a href='#{obj.url}'>#{obj.name}</a> | #{obj.desc}</li>"
end

indexdata += "</ul>"

get "/" do
  "<h1>XSSMaze</h1>
   <p>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>
   <p>All vulnerable parameters are named <code style='color: red;'>query</code>.</p>
   <p>You can find several vulnerable cases in the list below.</p>
   <hr>
   <p>Endpoint Map: <a href='/map/text'>Text</a> / <a href='/map/json'>JSON</a></p>
   " + indexdata
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
