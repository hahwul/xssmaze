Xssmaze.push("trustedtypes-level1", "/trustedtypes/level1/?query=a", "Trusted Types report-only header, sink reachable")
maze_get "/trustedtypes/level1/" do |env|
  env.response.headers["Content-Security-Policy-Report-Only"] = "require-trusted-types-for 'script'"
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     document.getElementById('out').innerHTML = #{query.to_json};
   </script>"
end

Xssmaze.push("trustedtypes-level2", "/trustedtypes/level2/?query=a", "TT enforced, but page exposes a permissive policy")
maze_get "/trustedtypes/level2/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types default"
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     if (window.trustedTypes && trustedTypes.createPolicy) {
       trustedTypes.createPolicy('default', { createHTML: function (s) { return s; } });
     }
     document.getElementById('out').innerHTML = #{query.to_json};
   </script>"
end

Xssmaze.push("trustedtypes-level3", "/trustedtypes/level3/?query=a", "TT policy that wraps but does not sanitize")
maze_get "/trustedtypes/level3/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types loose"
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     var p = trustedTypes.createPolicy('loose', { createHTML: function (s) { return '<span>' + s + '</span>'; } });
     document.getElementById('out').innerHTML = p.createHTML(#{query.to_json});
   </script>"
end

Xssmaze.push("trustedtypes-level4", "/trustedtypes/level4/?query=a", "TT only enforced for script, not innerHTML")
maze_get "/trustedtypes/level4/" do |env|
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     document.getElementById('out').innerHTML = #{query.to_json};
   </script>"
end

Xssmaze.push("trustedtypes-level5", "/trustedtypes/level5/?query=a", "policy strips <script> only, allows event handlers")
maze_get "/trustedtypes/level5/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types nso"
  query = env.params.query["query"]
  "<div id='out'></div>
   <script>
     var p = trustedTypes.createPolicy('nso', {
       createHTML: function (s) { return s.replace(/<script[^>]*>.*?<\\/script>/gi, ''); }
     });
     document.getElementById('out').innerHTML = p.createHTML(#{query.to_json});
   </script>"
end
