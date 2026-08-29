Xssmaze.push("metarefresh-level1", "/metarefresh/level1/?url=a", "<meta http-equiv=refresh> url unfiltered", "GET", ["url"],
  vuln: "reflected-attr", delivery: ["query"], note: "browsers refuse javascript: in a meta refresh; break out of the single-quoted content attribute")
maze_get "/metarefresh/level1/" do |env|
  url = env.params.query.fetch("url", "")
  "<meta http-equiv='refresh' content='0;url=#{url}'>"
end

Xssmaze.push("metarefresh-level2", "/metarefresh/level2/?url=a", "meta refresh with quote-strip filter", "GET", ["url"],
  vuln: "non-xss-control", delivery: ["query"], exploitable: false, note: "both quote characters are stripped so the single-quoted content attribute cannot be broken out of, and browsers refuse both javascript: and top-level data: navigation from a meta refresh; only an open redirect is left")
maze_get "/metarefresh/level2/" do |env|
  url = env.params.query.fetch("url", "").gsub("'", "").gsub("\"", "")
  "<meta http-equiv='refresh' content='0;url=#{url}'>"
end

Xssmaze.push("metarefresh-level3", "/metarefresh/level3/?url=a", "meta refresh blocking literal javascript: only", "GET", ["url"],
  vuln: "reflected-attr", delivery: ["query"], note: "the javascript: strip is a red herring, since browsers refuse that scheme in a meta refresh anyway; the single-quoted content attribute is what breaks out")
maze_get "/metarefresh/level3/" do |env|
  url = env.params.query.fetch("url", "").gsub("javascript:", "")
  "<meta http-equiv='refresh' content='2;url=#{url}'>"
end

Xssmaze.push("metarefresh-level4", "/metarefresh/level4/?url=a", "meta refresh content fully under user control", "GET", ["url"],
  vuln: "reflected-attr", delivery: ["query"], note: "the whole content attribute is user-controlled, but it is still an attribute: break out of the double quote")
maze_get "/metarefresh/level4/" do |env|
  url = env.params.query.fetch("url", "")
  "<meta http-equiv='refresh' content=\"#{url}\">"
end
