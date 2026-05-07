def load_mutation_observer_xss
  Xssmaze.push("mobserver-level1", "/mobserver/level1/?query=a", "MutationObserver re-applies textContent as innerHTML")
  maze_get "/mobserver/level1/" do |env|
    query = env.params.query["query"]
    "<div id='out'></div>
     <script>
       var o = new MutationObserver(function (muts) {
         muts.forEach(function (m) {
           m.addedNodes.forEach(function (n) {
             if (n.nodeType === 3) document.getElementById('out').innerHTML = n.textContent;
           });
         });
       });
       o.observe(document.body, {childList: true});
       var t = document.createTextNode(#{query.to_json});
       document.body.appendChild(t);
     </script>"
  end

  Xssmaze.push("mobserver-level2", "/mobserver/level2/?query=a", "observer copies attribute value into inline event handler-bearing element")
  maze_get "/mobserver/level2/" do |env|
    query = env.params.query["query"]
    "<div id='probe' data-payload='#{query}'></div>
     <div id='out'></div>
     <script>
       var probe = document.getElementById('probe');
       var out = document.getElementById('out');
       new MutationObserver(function () {
         out.innerHTML = '<span title=\"' + probe.dataset.payload + '\">x</span>';
       }).observe(probe, {attributes: true});
       probe.dataset.payload = probe.dataset.payload + '!';
     </script>"
  end

  Xssmaze.push("mobserver-level3", "/mobserver/level3/?query=a", "observer relays addedNodes innerHTML between containers")
  maze_get "/mobserver/level3/" do |env|
    query = env.params.query["query"]
    "<div id='src'></div><div id='out'></div>
     <script>
       new MutationObserver(function (muts) {
         muts.forEach(function (m) {
           m.addedNodes.forEach(function (n) {
             if (n.nodeType === 1) document.getElementById('out').innerHTML = n.outerHTML;
           });
         });
       }).observe(document.getElementById('src'), {childList: true});
       document.getElementById('src').insertAdjacentHTML('beforeend', #{query.to_json});
     </script>"
  end

  Xssmaze.push("mobserver-level4", "/mobserver/level4/?query=a", "characterData observer re-emits data via document.write")
  maze_get "/mobserver/level4/" do |env|
    query = env.params.query["query"]
    "<div id='src'>x</div>
     <script>
       var s = document.getElementById('src');
       new MutationObserver(function () { document.write(s.textContent); }).observe(s.firstChild, {characterData: true});
       s.firstChild.data = #{query.to_json};
     </script>"
  end
end
