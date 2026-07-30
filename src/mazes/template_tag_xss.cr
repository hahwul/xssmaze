Xssmaze.push("tplel-level1", "/tplel/level1/?query=a", "<template> content cloned into innerHTML",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "inert <template> content is read back out and re-injected with innerHTML, which activates it")
maze_get "/tplel/level1/" do |env|
  query = env.params.query["query"]
  "<template id='t'>#{query}</template>
   <div id='out'></div>
   <script>
     var t = document.getElementById('t');
     document.getElementById('out').innerHTML = t.innerHTML;
   </script>"
end

Xssmaze.push("tplel-level2", "/tplel/level2/?query=a", "template.content.cloneNode then appendChild",
  vuln: "dom", sources: ["server-reflected"], sinks: ["template.content-clone"], delivery: ["query"], note: "template content is cloned and appended; cloned <script> stays inert, so use an event handler")
maze_get "/tplel/level2/" do |env|
  query = env.params.query["query"]
  "<template id='t'><span>#{query}</span></template>
   <div id='out'></div>
   <script>
     var t = document.getElementById('t');
     var clone = t.content.cloneNode(true);
     document.getElementById('out').appendChild(clone);
   </script>"
end

Xssmaze.push("tplel-level3", "/tplel/level3/?query=a", "<template>'s inert script is reactivated by setHTML",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"])
maze_get "/tplel/level3/" do |env|
  query = env.params.query["query"]
  "<template id='t'><img src=x><script>console.log('inert')</script></template>
   <div id='out'></div>
   <script>
     var t = document.getElementById('t');
     var html = t.innerHTML + #{query.to_json};
     document.getElementById('out').innerHTML = html;
   </script>"
end

Xssmaze.push("tplel-level4", "/tplel/level4/?query=a", "<template> content concatenated into outer innerHTML",
  vuln: "dom", sources: ["server-reflected"], sinks: ["template.innerHTML", "innerHTML"], delivery: ["query"])
maze_get "/tplel/level4/" do |env|
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     var t = document.createElement('template');
     t.innerHTML = #{query.to_json};
     document.getElementById('out').innerHTML = t.innerHTML;
   </script>"
end
