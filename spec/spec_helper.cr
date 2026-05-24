require "spec"
require "json"
require "kemal"
require "spec-kemal"

# Ensure `Xssmaze::Server.start!` wires routes without calling `Kemal.run`.
ENV["KEMAL_ENV"] = "test" unless ENV["KEMAL_ENV"]?

require "../src/xssmaze"

require "../src/filters"
require "../src/maze"
