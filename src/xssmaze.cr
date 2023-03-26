require "kemal"
require "./maze"
require "./mazes/basic"

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

# Index
list = Xssmaze.get
indexdata = "<ul>"

list.each do |obj|
  puts "loaded - " + obj.name
indexdata += "<li><a href='#{obj.url}'>#{obj.name}</a> | #{obj.desc}</li>"
end

indexdata += "</ul>"

get "/" do
  "<h1>Index</h1><hr>"+indexdata
end

Kemal.run