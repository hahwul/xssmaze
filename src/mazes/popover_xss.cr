def load_popover_xss
  Xssmaze.push("popover-level1", "/popover/level1/?query=a", "popover content raw reflection (innerHTML of popover element)")
  maze_get "/popover/level1/" do |env|
    query = env.params.query["query"]
    "<button popovertarget='p'>open</button>
     <div id='p' popover>#{query}</div>"
  end

  Xssmaze.push("popover-level2", "/popover/level2/?query=a", "auto-popover with reflected anchor name (attribute breakout)")
  maze_get "/popover/level2/" do |env|
    query = env.params.query["query"].gsub("<", "&lt;").gsub(">", "&gt;")
    "<div popover='auto' id='#{query}' style='anchor-name:--a'>x</div>
     <button popovertarget='#{query}'>open</button>"
  end

  Xssmaze.push("popover-level3", "/popover/level3/?query=a", "popover triggered via showPopover() with innerHTML sink")
  maze_get "/popover/level3/" do |env|
    query = env.params.query["query"]
    "<div id='p' popover></div>
     <script>
       var p = document.getElementById('p');
       p.innerHTML = #{query.to_json};
       p.showPopover();
     </script>"
  end
end
