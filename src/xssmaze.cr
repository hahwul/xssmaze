require "kemal"
require "./maze"
require "./mazes/**"

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

# Routes
load_basic
load_dom
load_header
load_path
load_post

# Index
list = Xssmaze.get
indexdata = "<ul>"

list.each do |obj|
  puts "loaded - " + obj.name
indexdata += "<li><a href='#{obj.url}'>#{obj.name}</a> | #{obj.desc}</li>"
end

indexdata += "</ul>"

get "/" do
  "<h1>XSSMaze</h1>
   <p>XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools.</p>
   <p>You can find several vulnerable cases in the list below.</p>
   <hr>"+indexdata
end

Kemal.run