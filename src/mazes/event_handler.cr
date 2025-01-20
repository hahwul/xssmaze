def common_logic(query)
  query = query.gsub("<", "").gsub(">", "")
  "<div #{query}>Event Handler Test :: #{query}</div>"
end

def sanitize_query(query, level)
  case level
  when 2
    query = query.gsub(/on(error|load|click)/i, "")
  when 3
    query = query.gsub(/on(error|load|click|mouseover|focus|blur|keypress)/i, "")
  when 4
    query = query.gsub(/on(error|load|click|mouseover|focus|blur|keypress|animation(start|end|iteration)|drag(start|end|over|leave))/i, "")
    query = query.gsub(/javascript:/i, "")
  when 5
    query = query.gsub(/on(afterprint|afterscriptexecute|animation(cancel|end|iteration|start)|auxclick|before(copy|cut|input|unload)|blur|cancel|canplay|canplaythrough|change|click|close|contextmenu|copy|cuechange|cut|dblclick|drag(start|end|over|leave)|drop|durationchange|ended|error|focus(in|out)?|fullscreenchange|hashchange|input|invalid|keydown|keypress|keyup|load(start|ed(data|metadata)?)?|message|mousedown|mouseenter|mouseleave|mousemove|mouseout|mouseover|mouseup|pagehide|pageshow|paste|pause|play(ing)?|pointer(cancel|down|enter|leave|move|out|over|up)|progress|ratechange|reset|resize|scroll|seeked|seeking|select(start|end|ionchange)?|show|submit|suspend|timeupdate|toggle|touch(end|move|start)|transition(cancel|end|run|start)|unhandledrejection|unload|volumechange|waiting|wheel|webkit(animation(start|end|iteration)|mouse(force(willbegin|changed|down|up)|playbacktargetavailabilitychanged)|presentationmodechanged|fullscreenchange|willrevealbottom|transitionend))/i, "")
  end
  query
end

def load_eventhandler_xss
  Xssmaze.push("eventhandler-xss-level1", "/eventhandler/level1/?query=a", "eventhandler-xss (basic)")
  get "/eventhandler/level1/" do |env|
    query = env.params.query["query"]
    common_logic(query)
  end

  Xssmaze.push("eventhandler-xss-level2", "/eventhandler/level2/?query=a", "eventhandler-xss (level 2)")
  get "/eventhandler/level2/" do |env|
    query = env.params.query["query"]
    query = sanitize_query(query, 2)
    common_logic(query)
  end

  Xssmaze.push("eventhandler-xss-level3", "/eventhandler/level3/?query=a", "eventhandler-xss (level 3)")
  get "/eventhandler/level3/" do |env|
    query = env.params.query["query"]
    query = sanitize_query(query, 3)
    common_logic(query)
  end

  Xssmaze.push("eventhandler-xss-level4", "/eventhandler/level4/?query=a", "eventhandler-xss (level 4)")
  get "/eventhandler/level4/" do |env|
    query = env.params.query["query"]
    query = sanitize_query(query, 4)
    common_logic(query)
  end

  Xssmaze.push("eventhandler-xss-level5", "/eventhandler/level5/?query=a", "eventhandler-xss (level 5)")
  get "/eventhandler/level5/" do |env|
    query = env.params.query["query"]
    query = sanitize_query(query, 5)
    common_logic(query)
  end
end
