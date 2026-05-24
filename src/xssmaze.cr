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

# Keep spec output clean and avoid boot-time side effects during tests.
banner unless ENV["KEMAL_ENV"]? == "test"
# In specs we set KEMAL_ENV=test and use spec-kemal to exercise routes
# without binding a real TCP socket.
Xssmaze::Server.start!(run_server: ENV["KEMAL_ENV"]? != "test")
