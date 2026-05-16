require "json"
require "compress/gzip"
require "digest/sha1"
require "kemal"

require "./maze"
require "./filters"
require "./route_helper"
require "./registry"
require "./assets"
require "./catalog"
require "./banner"
require "./mazes/**"
require "./server"

banner
Xssmaze::Server.start!
