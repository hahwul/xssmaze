def load_popover_xss
  Xssmaze.push("popover-level1", "/popover/level1/?query=a", "popover content raw reflection")
  maze_get "/popover/level1/" do |env|
    query = env.params.query["query"]
    "<button popovertarget='p'>open</button>
     <div id='p' popover>#{query}</div>"
  end

  Xssmaze.push("popover-level2", "/popover/level2/?query=a", "popovertargetaction attribute under user control")
  maze_get "/popover/level2/" do |env|
    query = env.params.query["query"]
    "<button popovertarget='p' popovertargetaction='#{query}'>act</button>
     <div id='p' popover>hello</div>"
  end

  Xssmaze.push("popover-level3", "/popover/level3/?query=a", "auto-popover with reflected anchor name")
  maze_get "/popover/level3/" do |env|
    query = env.params.query["query"].gsub("<", "&lt;").gsub(">", "&gt;")
    "<div popover='auto' id='#{query}' style='anchor-name:--a'>x</div>
     <button popovertarget='#{query}'>open</button>"
  end

  Xssmaze.push("popover-level4", "/popover/level4/?query=a", "popover triggered via showPopover() with innerHTML sink")
  maze_get "/popover/level4/" do |env|
    query = env.params.query["query"]
    "<div id='p' popover></div>
     <script>
       var p = document.getElementById('p');
       p.innerHTML = #{query.to_json};
       p.showPopover();
     </script>"
  end
end
