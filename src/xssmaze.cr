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
require "./ui"
require "./banner"
require "./mazes/**"
require "./server"

# The banner is printed from `Server.start!`, once the CLI has been parsed,
# so it can report the address and the catalog size it is really serving.
#
# In specs we set KEMAL_ENV=test and use spec-kemal to exercise routes
# without binding a real TCP socket.
Xssmaze::Server.start!(run_server: ENV["KEMAL_ENV"]? != "test")
