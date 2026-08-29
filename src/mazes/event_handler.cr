module EventHandlerHelper
  def self.build_html(query : String) : String
    query = Filters.strip_angles(query)
    "<div #{query}>Event Handler Test :: #{query}</div>"
  end

  def self.sanitize(query : String, level : Int32) : String
    case level
    when 2
      query.gsub(/on(error|load|click)/i, "")
    when 3
      query.gsub(/on(error|load|click|mouseover|focus|blur|keypress)/i, "")
    when 4
      filtered = query.gsub(/on(error|load|click|mouseover|focus|blur|keypress|animation(start|end|iteration)|drag(start|end|over|leave))/i, "")
      filtered.gsub(/javascript:/i, "")
    when 5
      query.gsub(/on(afterprint|afterscriptexecute|animation(cancel|end|iteration|start)|auxclick|before(copy|cut|input|unload)|blur|cancel|canplay|canplaythrough|change|click|close|contextmenu|copy|cuechange|cut|dblclick|drag(start|end|over|leave)|drop|durationchange|ended|error|focus(in|out)?|fullscreenchange|hashchange|input|invalid|keydown|keypress|keyup|load(start|ed(data|metadata)?)?|message|mousedown|mouseenter|mouseleave|mousemove|mouseout|mouseover|mouseup|pagehide|pageshow|paste|pause|play(ing)?|pointer(cancel|down|enter|leave|move|out|over|up)|progress|ratechange|reset|resize|scroll|sought|seeking|select(start|end|ionchange)?|show|submit|suspend|timeupdate|toggle|touch(end|move|start)|transition(cancel|end|run|start)|unhandledrejection|unload|volumechange|waiting|wheel|webkit(animation(start|end|iteration)|mouse(force(willbegin|changed|down|up)|playbacktargetavailabilitychanged)|presentationmodechanged|fullscreenchange|willrevealbottom|transitionend))/i, "")
    else
      query
    end
  end
end

Xssmaze.push("eventhandler-xss-level1", "/eventhandler/level1/?query=a", "eventhandler-xss (basic)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are stripped, so no tag can be opened; the payload has to be a bare attribute injected into the wrapper <div ...>, e.g. onmouseover=alert(1), and needs its event to fire")
maze_get "/eventhandler/level1/" do |env|
  query = env.params.query["query"]
  EventHandlerHelper.build_html(query)
end

Xssmaze.push("eventhandler-xss-level2", "/eventhandler/level2/?query=a", "eventhandler-xss (level 2)",
  vuln: "reflected-attr", delivery: ["query"], note: "as level 1, and onerror/onload/onclick are removed by name; other handlers survive")
maze_get "/eventhandler/level2/" do |env|
  query = EventHandlerHelper.sanitize(env.params.query["query"], 2)
  EventHandlerHelper.build_html(query)
end

Xssmaze.push("eventhandler-xss-level3", "/eventhandler/level3/?query=a", "eventhandler-xss (level 3)",
  vuln: "reflected-attr", delivery: ["query"], note: "as level 1, and seven handler names are removed; unlisted ones such as ondblclick survive")
maze_get "/eventhandler/level3/" do |env|
  query = EventHandlerHelper.sanitize(env.params.query["query"], 3)
  EventHandlerHelper.build_html(query)
end

Xssmaze.push("eventhandler-xss-level4", "/eventhandler/level4/?query=a", "eventhandler-xss (level 4)",
  vuln: "reflected-attr", delivery: ["query"], note: "as level 1, and animation/drag handlers plus javascript: are removed; ontoggle and onpointerover survive")
maze_get "/eventhandler/level4/" do |env|
  query = EventHandlerHelper.sanitize(env.params.query["query"], 4)
  EventHandlerHelper.build_html(query)
end

Xssmaze.push("eventhandler-xss-level5", "/eventhandler/level5/?query=a", "eventhandler-xss (level 5)",
  vuln: "reflected-attr", delivery: ["query"], note: "as level 1, with a long handler denylist stripped in a single pass, so ononclickclick= rejoins into onclick=")
maze_get "/eventhandler/level5/" do |env|
  query = EventHandlerHelper.sanitize(env.params.query["query"], 5)
  EventHandlerHelper.build_html(query)
end
