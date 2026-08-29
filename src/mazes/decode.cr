require "base64"

Xssmaze.push("decode-level1", "/decode/level1/?query=a", "base64 decode",
  vuln: "reflected-html", delivery: ["query"], note: "the value must be valid base64; anything else answers Decode Error, so the payload is the base64 of the markup")
maze_get "/decode/level1/" do |env|
  Base64.decode_string(env.params.query.fetch("query", ""))
rescue
  "Decode Error"
end

Xssmaze.push("decode-level2", "/decode/level2/?query=a", "url decode",
  vuln: "reflected-html", delivery: ["query"], note: "a literal < is rejected, but the server URL-decodes once afterwards, so send %253C (which arrives as %3C)")
maze_get "/decode/level2/" do |env|
  if env.params.query.fetch("query", "").includes?("<")
    "Detect Special Character"
  else
    URI.decode(env.params.query.fetch("query", ""))
  end
rescue
  "Decode Error"
end

Xssmaze.push("decode-level3", "/decode/level3/?query=a", "double url decode",
  vuln: "reflected-html", delivery: ["query"], note: "URL-decoded once, checked for <, then decoded again; send %25253C so the check sees %3C")
maze_get "/decode/level3/" do |env|
  data = URI.decode(env.params.query.fetch("query", ""))
  if data.includes?("<")
    "Detect Special Character"
  else
    URI.decode(data)
  end
rescue
  "Decode Error"
end

Xssmaze.push("decode-level4", "/decode/level4/?query=a", "double base64 decode",
  vuln: "reflected-html", delivery: ["query"], note: "the value is base64-decoded twice; anything else answers Decode Error")
maze_get "/decode/level4/" do |env|
  data = Base64.decode_string(env.params.query.fetch("query", ""))
  Base64.decode_string(data)
rescue
  "Decode Error"
end
