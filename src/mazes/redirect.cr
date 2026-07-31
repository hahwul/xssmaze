# Open-redirect / `javascript:` Location sinks.
#
# The catalog URLs carry `?query=` like every other maze: these handlers used
# to advertise a bare path, so any tool that crawled /map/* got a 500
# (KeyError) instead of the level. Missing param now falls back to "/".
#
# `header_value` strips CR/LF only — Crystal raises rather than emitting a
# split response, so without it a CRLF payload was a 500, not a lesson. The
# `javascript:` sink these levels exist to teach is untouched.

Xssmaze.push("redirect-level1", "/redirect/level1/?query=/", "query param")
maze_get "/redirect/level1/" do |env|
  env.redirect Xssmaze.header_value(env.params.query.fetch("query", "/"))
end

Xssmaze.push("redirect-level2", "/redirect/level2/?query=/", "query param, strips 'javascript'")
maze_get "/redirect/level2/" do |env|
  query = env.params.query.fetch("query", "/").gsub("javascript", "")
  env.redirect Xssmaze.header_value(query)
end

Xssmaze.push("redirect-level3", "/redirect/level3/?query=/", "query param, lowercased then strips 'javascript'")
maze_get "/redirect/level3/" do |env|
  query = env.params.query.fetch("query", "/").downcase.gsub("javascript", "")
  env.redirect Xssmaze.header_value(query)
end

Xssmaze.push("redirect-level4", "/redirect/level4/?query=/", "query param, two lowercase+strip passes")
maze_get "/redirect/level4/" do |env|
  query = env.params.query.fetch("query", "/")
    .downcase.gsub("javascript", "")
    .downcase.gsub("javascript", "")
  env.redirect Xssmaze.header_value(query)
end
