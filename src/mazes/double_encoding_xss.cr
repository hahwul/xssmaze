require "base64"

def load_double_encoding_xss
  # Level 1: Server performs double URL decode before reflection
  # Exploit: Send double-URL-encoded payload e.g. %253Cscript%253Ealert(1)%253C/script%253E
  # First decode: %3Cscript%3Ealert(1)%3C/script%3E, second decode: <script>alert(1)</script>
  Xssmaze.push("dblenc-level1", "/dblenc/level1/?query=a", "double URL decode before reflection")
  maze_get "/dblenc/level1/" do |env|
    query = env.params.query["query"]

    begin
      decoded = URI.decode(URI.decode(query))
    rescue
      decoded = query
    end

    "<html><body>
    <h1>Double Encoding XSS Level 1</h1>
    <div>#{decoded}</div>
    </body></html>"
  end

  # Level 2: Server HTML-decodes entities then reflects raw
  # Exploit: Send &lt;script&gt;alert(1)&lt;/script&gt; which becomes <script>alert(1)</script>
  Xssmaze.push("dblenc-level2", "/dblenc/level2/?query=a", "HTML entity decode before reflection")
  maze_get "/dblenc/level2/" do |env|
    query = env.params.query["query"]

    decoded = query
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("&amp;", "&")
      .gsub("&quot;", "\"")
      .gsub("&#39;", "'")

    "<html><body>
    <h1>Double Encoding XSS Level 2</h1>
    <div>#{decoded}</div>
    </body></html>"
  end

  # Level 3: Server base64-decodes query then reflects raw
  # Exploit: Send base64-encoded payload e.g. PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==
  Xssmaze.push("dblenc-level3", "/dblenc/level3/?query=YQ==", "base64 decode before reflection")
  maze_get "/dblenc/level3/" do |env|
    query = env.params.query["query"]

    begin
      decoded = Base64.decode_string(query)
    rescue
      decoded = "Decode Error"
    end

    "<html><body>
    <h1>Double Encoding XSS Level 3</h1>
    <div>#{decoded}</div>
    </body></html>"
  end

  # Level 4: Server performs single URL decode then reflects raw
  # Exploit: Send %3Cscript%3Ealert(1)%3C/script%3E which decodes to <script>alert(1)</script>
  Xssmaze.push("dblenc-level4", "/dblenc/level4/?query=a", "single URL decode before reflection")
  maze_get "/dblenc/level4/" do |env|
    query = env.params.query["query"]

    begin
      decoded = URI.decode(query)
    rescue
      decoded = query
    end

    "<html><body>
    <h1>Double Encoding XSS Level 4</h1>
    <div>#{decoded}</div>
    </body></html>"
  end
end
