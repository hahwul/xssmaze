def load_meta_refresh_xss
  Xssmaze.push("metarefresh-level1", "/metarefresh/level1/?url=a", "<meta http-equiv=refresh> url unfiltered", "GET", ["url"])
  maze_get "/metarefresh/level1/" do |env|
    url = env.params.query["url"]
    "<meta http-equiv='refresh' content='0;url=#{url}'>"
  end

  Xssmaze.push("metarefresh-level2", "/metarefresh/level2/?url=a", "meta refresh with quote-strip filter", "GET", ["url"])
  maze_get "/metarefresh/level2/" do |env|
    url = env.params.query["url"].gsub("'", "").gsub("\"", "")
    "<meta http-equiv='refresh' content='0;url=#{url}'>"
  end

  Xssmaze.push("metarefresh-level3", "/metarefresh/level3/?url=a", "meta refresh blocking literal javascript: only", "GET", ["url"])
  maze_get "/metarefresh/level3/" do |env|
    url = env.params.query["url"].gsub("javascript:", "")
    "<meta http-equiv='refresh' content='2;url=#{url}'>"
  end

  Xssmaze.push("metarefresh-level4", "/metarefresh/level4/?url=a", "meta refresh content fully under user control", "GET", ["url"])
  maze_get "/metarefresh/level4/" do |env|
    url = env.params.query["url"]
    "<meta http-equiv='refresh' content=\"#{url}\">"
  end
end
