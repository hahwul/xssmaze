Xssmaze.push("path-level1", "/path/level1/a", "reflected", "GET", [":path"],
  vuln: "reflected-html", delivery: ["path"], note: "reflects the :name path segment (served as text/html)")
get "/path/level1/:name" do |env|
  name = env.params.url["name"]
  "Hi #{name}"
end

Xssmaze.push("path-level2", "/path/level2/a", "escape to %2f", "GET", [":path"],
  vuln: "reflected-html", delivery: ["path"], note: "a literal %2f strip does nothing after Kemal has decoded the segment")
get "/path/level2/:name" do |env|
  name = env.params.url["name"].gsub("%2f", "")
  "Hi #{name}"
end

Xssmaze.push("path-level3", "/path/level3/a", "escape to %20", "GET", [":path"],
  vuln: "reflected-html", delivery: ["path"], note: "spaces stripped; use / or a non-space vector")
get "/path/level3/:name" do |env|
  name = env.params.url["name"].gsub(" ", "").gsub("%20", "")
  "Hi #{name}"
end

Xssmaze.push("path-level4", "/path/level4/a", "escape to %2f and %20", "GET", [":path"],
  vuln: "reflected-html", delivery: ["path"])
get "/path/level4/:name" do |env|
  name = env.params.url["name"].gsub("%2f", "").gsub("%20", "")
  "Hi #{name}"
end
