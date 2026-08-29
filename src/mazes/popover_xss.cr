Xssmaze.push("popover-level1", "/popover/level1/?query=a", "popover content raw reflection (innerHTML of popover element)",
  vuln: "reflected-html", delivery: ["query"], note: "a closed popover is still parsed, so the injected markup runs without the popover ever being opened")
maze_get "/popover/level1/" do |env|
  query = env.params.query["query"]
  "<button popovertarget='p'>open</button>
   <div id='p' popover>#{query}</div>"
end

Xssmaze.push("popover-level2", "/popover/level2/?query=a", "auto-popover with reflected anchor name (attribute breakout)",
  vuln: "reflected-attr", delivery: ["query"], note: "angle brackets are encoded, so break out of one of the two single-quoted attributes; the button copy accepts autofocus plus onfocus, which needs no interaction")
maze_get "/popover/level2/" do |env|
  query = env.params.query["query"].gsub("<", "&lt;").gsub(">", "&gt;")
  "<div popover='auto' id='#{query}' style='anchor-name:--a'>x</div>
   <button popovertarget='#{query}'>open</button>"
end

Xssmaze.push("popover-level3", "/popover/level3/?query=a", "popover triggered via showPopover() with innerHTML sink",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "query.to_json blocks a JS-string breakout, but the value still reaches innerHTML as raw HTML")
maze_get "/popover/level3/" do |env|
  query = env.params.query["query"]
  "<div id='p' popover></div>
   <script>
     var p = document.getElementById('p');
     p.innerHTML = #{query.to_json};
     p.showPopover();
   </script>"
end
