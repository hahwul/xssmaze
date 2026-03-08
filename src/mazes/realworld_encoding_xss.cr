require "base64"

def load_realworld_encoding
  # Level 1: Triple URL decode
  # Server checks after first decode, but applies three total decodes before reflecting
  # Requires triple URL-encoded payload (e.g., %25253Cscript%25253E...)
  Xssmaze.push("realworld-encoding-level1", "/realworld-encoding/level1/?query=a", "triple URL decode")
  maze_get "/realworld-encoding/level1/" do |env|
    begin
      data = URI.decode(env.params.query["query"])
      if data.includes?("<") || data.includes?(">")
        "Detect Special Character"
      else
        data = URI.decode(data)
        if data.includes?("<") || data.includes?(">")
          "Detect Special Character"
        else
          URI.decode(data)
        end
      end
    rescue
      "Decode Error"
    end
  end

  # Level 2: Unicode normalization (NFKC)
  # Fullwidth characters like U+FF1C (＜) normalize to < (U+003C)
  # Server blocks literal < and > but normalizes Unicode before reflecting
  Xssmaze.push("realworld-encoding-level2", "/realworld-encoding/level2/?query=a", "Unicode NFKC normalization bypass")
  maze_get "/realworld-encoding/level2/" do |env|
    begin
      query = env.params.query["query"]
      if query.includes?("<") || query.includes?(">")
        "Detect Special Character"
      else
        # NFKC normalization: fullwidth chars become ASCII equivalents
        normalized = query.unicode_normalize(:nfkc)
        "<html><body><h1>Unicode Normalization Level</h1><div>#{normalized}</div></body></html>"
      end
    rescue
      "Decode Error"
    end
  end

  # Level 3: HTML entity double decode
  # Server decodes HTML entities once, then reflects the result in HTML context
  # The browser will decode the remaining entities, so nested entities work
  # e.g., &amp;lt; -> &lt; (server decode) -> < (browser decode)
  Xssmaze.push("realworld-encoding-level3", "/realworld-encoding/level3/?query=a", "HTML entity double decode")
  maze_get "/realworld-encoding/level3/" do |env|
    begin
      query = env.params.query["query"]
      if query.includes?("<") || query.includes?(">")
        "Detect Special Character"
      else
        # Decode common HTML entities one layer
        decoded = query
          .gsub("&amp;", "&")
          .gsub("&lt;", "<")
          .gsub("&gt;", ">")
          .gsub("&quot;", "\"")
          .gsub("&#39;", "'")
          .gsub("&#x27;", "'")
          .gsub("&#x3c;", "<")
          .gsub("&#x3e;", ">")
          .gsub("&#x3C;", "<")
          .gsub("&#x3E;", ">")
          .gsub("&#60;", "<")
          .gsub("&#62;", ">")
        "<html><body><h1>HTML Entity Double Decode Level</h1><div>#{decoded}</div></body></html>"
      end
    rescue
      "Decode Error"
    end
  end

  # Level 4: Mixed encoding chain (Base64 + URL)
  # Server base64-decodes, then URL-decodes the result before reflecting
  # To exploit: URL-encode your payload, then base64-encode that result
  Xssmaze.push("realworld-encoding-level4", "/realworld-encoding/level4/?query=a", "base64 then URL decode chain")
  maze_get "/realworld-encoding/level4/" do |env|
    begin
      data = Base64.decode_string(env.params.query["query"])
      decoded = URI.decode(data)
      "<html><body><h1>Mixed Encoding Chain Level</h1><div>#{decoded}</div></body></html>"
    rescue
      "Decode Error"
    end
  end

  # Level 5: CSS style attribute injection
  # Input reflected inside a style attribute value
  # Can break out with "> or use expression()/url() for older browsers
  Xssmaze.push("realworld-encoding-level5", "/realworld-encoding/level5/?query=a", "CSS style attribute injection")
  maze_get "/realworld-encoding/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>CSS Style Attribute Injection Level</h1>
    <div style=\"color: #{query}\">Styled content</div>
    </body></html>"
  end

  # Level 6: CSS @import / style body injection
  # Input reflected inside <style> block in a property value
  # Can break out with </style> to inject HTML, or use url(javascript:) in some contexts
  Xssmaze.push("realworld-encoding-level6", "/realworld-encoding/level6/?query=a", "CSS style tag body injection")
  maze_get "/realworld-encoding/level6/" do |env|
    query = env.params.query["query"]

    "<html><head>
    <style>
    body { background: #{query}; }
    </style>
    </head><body>
    <h1>CSS @import Injection Level</h1>
    <div>Background controlled by user input</div>
    </body></html>"
  end

  # Level 7: SVG + URL encoding combo
  # Input is URL-decoded once, then placed inside an SVG element
  # Requires URL-encoded SVG XSS payload (e.g., onload handler)
  Xssmaze.push("realworld-encoding-level7", "/realworld-encoding/level7/?query=a", "SVG with URL decode combo")
  maze_get "/realworld-encoding/level7/" do |env|
    begin
      query = env.params.query["query"]
      if query.includes?("<") || query.includes?(">")
        "Detect Special Character"
      else
        decoded = URI.decode(query)
        "<html><body>
        <h1>SVG + Encoding Combo Level</h1>
        <svg><text>#{decoded}</text></svg>
        </body></html>"
      end
    rescue
      "Decode Error"
    end
  end

  # Level 8: JSON string escape bypass
  # Input reflected inside a JSON string within a <script> tag
  # Server escapes quotes and backslashes but does NOT sanitize </script>
  # Payload: </script><script>alert(1)</script>
  Xssmaze.push("realworld-encoding-level8", "/realworld-encoding/level8/?query=a", "JSON string with script tag breakout")
  maze_get "/realworld-encoding/level8/" do |env|
    query = env.params.query["query"]
    # Escape quotes and backslashes (typical JSON string escaping)
    escaped = query.gsub("\\", "\\\\").gsub("\"", "\\\"").gsub("'", "\\'")
    # But notably does NOT filter </script>

    "<html><body>
    <h1>JSON String Escape Bypass Level</h1>
    <div id='output'></div>
    <script>
    var config = {\"name\": \"#{escaped}\"};
    document.getElementById('output').textContent = config.name;
    </script>
    </body></html>"
  end
end
