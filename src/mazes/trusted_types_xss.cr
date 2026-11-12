Xssmaze.push("trustedtypes-level1", "/trustedtypes/level1/?query=a", "Trusted Types report-only header, sink reachable",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "Trusted Types is sent report-only, so the sink is not blocked")
maze_get "/trustedtypes/level1/" do |env|
  env.response.headers["Content-Security-Policy-Report-Only"] = "require-trusted-types-for 'script'"
  query = env.params.query.fetch("query", "")
  "<div id='out'></div>
   <script>
     document.getElementById('out').innerHTML = #{query.to_json};
   </script>"
end

Xssmaze.push("trustedtypes-level2", "/trustedtypes/level2/?query=a", "TT enforced, but page exposes a permissive policy",
  vuln: "dom", sources: ["server-reflected"], sinks: ["innerHTML"], delivery: ["query"], note: "Trusted Types enforced, but the page installs a permissive 'default' policy")
maze_get "/trustedtypes/level2/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types default"
  query = env.params.query.fetch("query", "")
  "<div id='out'></div>
   <script>
     if (window.trustedTypes && trustedTypes.createPolicy) {
       trustedTypes.createPolicy('default', { createHTML: function (s) { return s; } });
     }
     document.getElementById('out').innerHTML = #{query.to_json};
   </script>"
end

Xssmaze.push("trustedtypes-level3", "/trustedtypes/level3/?query=a", "TT policy that wraps but does not sanitize",
  vuln: "dom", sources: ["server-reflected"], sinks: ["trustedtypes.createHTML", "innerHTML"], delivery: ["query"], note: "the Trusted Types policy wraps the value but does not sanitize it")
maze_get "/trustedtypes/level3/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types loose"
  query = env.params.query.fetch("query", "")
  "<div id='out'></div>
   <script>
     var p = trustedTypes.createPolicy('loose', { createHTML: function (s) { return '<span>' + s + '</span>'; } });
     document.getElementById('out').innerHTML = p.createHTML(#{query.to_json});
   </script>"
end

# Trusted Types guards DOM sinks only. The innerHTML write below really is
# blocked (no policy exists, so the assignment throws), but the same value is
# also rendered server-side, and parser-inserted markup is outside TT entirely.
# `</` is escaped in the script copy so the heading is the only way out.
Xssmaze.push("trustedtypes-level4", "/trustedtypes/level4/?query=a", "TT enforced on the DOM sink, value also reflected server-side",
  vuln: "reflected-html", delivery: ["query"], note: "require-trusted-types-for 'script' is enforced with no policy, so the innerHTML write throws; the bug is the server-side reflection in the heading, which the HTML parser inserts and Trusted Types never sees")
maze_get "/trustedtypes/level4/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'"
  query = env.params.query.fetch("query", "")
  "<h1>Results for #{query}</h1>
   <div id='out'></div>
   <script>
     try {
       document.getElementById('out').innerHTML = #{query.to_json.gsub("</", "<\\/")};
     } catch (e) {
       document.getElementById('out').textContent = 'blocked by Trusted Types';
     }
   </script>"
end

Xssmaze.push("trustedtypes-level5", "/trustedtypes/level5/?query=a", "policy strips <script> only, allows event handlers",
  vuln: "dom", sources: ["server-reflected"], sinks: ["trustedtypes.createHTML", "innerHTML"], delivery: ["query"], note: "the policy strips <script> only; event-handler attributes still fire")
maze_get "/trustedtypes/level5/" do |env|
  env.response.headers["Content-Security-Policy"] = "require-trusted-types-for 'script'; trusted-types nso"
  query = env.params.query.fetch("query", "")
  "<div id='out'></div>
   <script>
     var p = trustedTypes.createPolicy('nso', {
       createHTML: function (s) { return s.replace(/<script[^>]*>.*?<\\/script>/gi, ''); }
     });
     document.getElementById('out').innerHTML = p.createHTML(#{query.to_json});
   </script>"
end
