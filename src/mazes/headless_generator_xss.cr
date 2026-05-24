# Headless Generator XSS
#
# Simulates backend PDF/Image generation services using headless browsers
# (Puppeteer, Playwright, Headless Chrome) that convert HTML/SVG to PDF/PNG
#
# These endpoints demonstrate vulnerabilities in backend rendering engines
# where user-supplied HTML/SVG is processed by a headless browser, potentially
# executing JavaScript in a server-side context.

# Storage for simulating webhook callbacks and execution logs
HEADLESS_CALLBACK_LOG = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

# Level 1: Basic HTML to PDF - No Filtering
# Accepts HTML input and simulates PDF generation with no sanitization
# Vulnerable to direct XSS execution in headless browser context
Xssmaze.push("headless-generator-level1", "/headless-generator/level1/", "HTML to PDF - no filtering", "POST", ["html"])
maze_get "/headless-generator/level1/" do |_|
  %(<form action='/headless-generator/level1/' method='post'>
      <textarea name='html' rows='10' cols='50'>&lt;h1&gt;Test Document&lt;/h1&gt;</textarea><br>
      <input type='submit' value='Generate PDF'>
    </form>)
end
maze_post "/headless-generator/level1/" do |env|
  html_input = env.params.body["html"]?.to_s

  # Simulate headless browser processing - reflects the HTML that would be rendered
  rendered_output = %(<div class="pdf-preview">
    <h3>PDF Generation Simulation</h3>
    <p>The following HTML will be rendered by headless browser:</p>
    <div class="rendered-content">
      #{html_input}
    </div>
    <p><em>In real scenario, any JavaScript in the HTML would execute in headless browser context</em></p>
  </div>)

  rendered_output
end

# Level 2: SVG to PNG - No Filtering
# Accepts SVG input for image generation
# SVG can contain script elements that execute during rendering
Xssmaze.push("headless-generator-level2", "/headless-generator/level2/", "SVG to PNG - no filtering", "POST", ["svg"])
maze_get "/headless-generator/level2/" do |_|
  %(<form action='/headless-generator/level2/' method='post'>
      <textarea name='svg' rows='10' cols='50'>&lt;svg xmlns="http://www.w3.org/2000/svg"&gt;&lt;circle cx="50" cy="50" r="40"/&gt;&lt;/svg&gt;</textarea><br>
      <input type='submit' value='Generate PNG'>
    </form>)
end
maze_post "/headless-generator/level2/" do |env|
  svg_input = env.params.body["svg"]?.to_s

  # Simulate SVG rendering - SVG scripts execute during headless browser rendering
  rendered_output = %(<div class="image-preview">
    <h3>PNG Generation Simulation</h3>
    <p>The following SVG will be rendered by headless browser:</p>
    <div class="rendered-svg">
      #{svg_input}
    </div>
    <p><em>SVG &lt;script&gt; tags execute during rendering in headless browser</em></p>
  </div>)

  rendered_output
end

# Level 3: HTML Sanitization with Bypass
# Implements basic tag filtering but bypassable
# Strips <script> tags but misses other execution vectors
Xssmaze.push("headless-generator-level3", "/headless-generator/level3/", "HTML sanitization bypass", "POST", ["html"])
maze_get "/headless-generator/level3/" do |_|
  %(<form action='/headless-generator/level3/' method='post'>
      <textarea name='html' rows='10' cols='50'>&lt;h1&gt;Test Document&lt;/h1&gt;</textarea><br>
      <input type='submit' value='Generate PDF'>
      <p><small>Note: &lt;script&gt; tags are filtered</small></p>
    </form>)
end
maze_post "/headless-generator/level3/" do |env|
  html_input = env.params.body["html"]?.to_s

  # Basic sanitization - only removes <script> tags (case-sensitive)
  sanitized = html_input.gsub(/<script[^>]*>.*?<\/script>/i, "")

  rendered_output = %(<div class="pdf-preview">
    <h3>PDF Generation Simulation (Sanitized)</h3>
    <p>HTML after sanitization:</p>
    <div class="rendered-content">
      #{sanitized}
    </div>
    <p><em>Bypass hint: Try event handlers, iframe srcdoc, or object/embed tags</em></p>
  </div>)

  rendered_output
end

# Level 4: SSRF via Internal URL Fetching
# Accepts HTML with external resources (img src, link href)
# Simulates headless browser fetching resources during rendering
Xssmaze.push("headless-generator-level4", "/headless-generator/level4/", "SSRF via resource loading", "POST", ["html"])
maze_get "/headless-generator/level4/" do |_|
  %(<form action='/headless-generator/level4/' method='post'>
      <textarea name='html' rows='10' cols='50'>&lt;img src="https://example.com/image.png"&gt;</textarea><br>
      <input type='submit' value='Generate PDF'>
      <p><small>Server fetches external resources during PDF generation</small></p>
    </form>)
end
maze_post "/headless-generator/level4/" do |env|
  html_input = env.params.body["html"]?.to_s

  # Extract URLs from img src, link href, etc.
  fetched_urls = [] of String
  html_input.scan(/(?:src|href)=["']([^"']+)["']/) do |match|
    url = match[1]
    fetched_urls << url
  end

  rendered_output = %(<div class="pdf-preview">
    <h3>PDF Generation Simulation</h3>
    <p>Resources fetched by headless browser:</p>
    <ul>
      #{fetched_urls.map { |url| "<li>#{HTML.escape(url)}</li>" }.join("\n")}
    </ul>
    <div class="rendered-content">
      #{html_input}
    </div>
    <p><em>SSRF vulnerability: Internal URLs (file://, http://169.254.169.254/) may be accessible</em></p>
  </div>)

  rendered_output
end

# Level 5: JavaScript Callback Simulation with Webhook
# Simulates JavaScript execution that triggers external callbacks
# Useful for testing out-of-band XSS detection
Xssmaze.push("headless-generator-level5", "/headless-generator/level5/", "JavaScript callback simulation", "POST", ["html", "callback_id"])
maze_get "/headless-generator/level5/" do |_|
  callback_id = Random::Secure.hex(8)
  %(<form action='/headless-generator/level5/' method='post'>
      <input type='hidden' name='callback_id' value='#{callback_id}'>
      <textarea name='html' rows='10' cols='50'>&lt;h1&gt;Test Document&lt;/h1&gt;</textarea><br>
      <input type='submit' value='Generate PDF'>
      <p><small>Your callback ID: <code>#{callback_id}</code></small></p>
      <p><small>Check results at: <a href='/headless-generator/level5/callback/#{callback_id}'>/callback/#{callback_id}</a></small></p>
    </form>)
end
maze_post "/headless-generator/level5/" do |env|
  html_input = env.params.body["html"]?.to_s
  callback_id = env.params.body["callback_id"]?.to_s

  # Simulate JavaScript execution detection
  js_detected = false
  callback_url = ""

  # Check for fetch/XMLHttpRequest calls
  if html_input =~ /fetch\s*\(|XMLHttpRequest|\.send\(/
    js_detected = true
    # Extract callback URL if present
    if match = html_input.match(/(?:fetch\s*\(|\.open\s*\([^,]*,)\s*["']([^"']+)["']/)
      callback_url = match[1]
      HEADLESS_CALLBACK_LOG[callback_id] << "JavaScript fetch/XHR detected: #{callback_url}"
    else
      HEADLESS_CALLBACK_LOG[callback_id] << "JavaScript execution detected"
    end
  end

  # Check for image beacons
  if html_input =~ /<img[^>]+src=["']https?:\/\/[^"']+/
    HEADLESS_CALLBACK_LOG[callback_id] << "Image beacon detected in HTML"
  end

  rendered_output = %(<div class="pdf-preview">
    <h3>PDF Generation Simulation</h3>
    <div class="rendered-content">
      #{html_input}
    </div>
    <p>JavaScript execution: <strong>#{js_detected ? "DETECTED" : "Not detected"}</strong></p>
    #{callback_url.empty? ? "" : "<p>Callback URL: <code>#{HTML.escape(callback_url)}</code></p>"}
    <p>Check your callback log: <a href='/headless-generator/level5/callback/#{HTML.escape(callback_id)}'>/callback/#{HTML.escape(callback_id)}</a></p>
  </div>)

  rendered_output
end

# Callback log viewer for Level 5
maze_get "/headless-generator/level5/callback/:id" do |env|
  callback_id = env.params.url["id"]
  logs = HEADLESS_CALLBACK_LOG[callback_id]? || [] of String

  %(<div class="callback-log">
    <h3>Callback Log for ID: #{HTML.escape(callback_id)}</h3>
    #{logs.empty? ? "<p>No callbacks received yet</p>" : "<ul>#{logs.map { |log| "<li>#{HTML.escape(log)}</li>" }.join("\n")}</ul>"}
    <p><a href='/headless-generator/level5/'>Back to Level 5</a></p>
  </div>)
end

# Level 6: Content-Type Validation Bypass
# Checks Content-Type but can be bypassed with polyglot files
# Accepts JSON input claiming to be HTML
Xssmaze.push("headless-generator-level6", "/headless-generator/level6/", "Content-Type validation bypass", "POST", ["content"])
maze_get "/headless-generator/level6/" do |_|
  %(<form action='/headless-generator/level6/' method='post'>
      <textarea name='content' rows='10' cols='50'>{"html": "&lt;h1&gt;Title&lt;/h1&gt;"}</textarea><br>
      <input type='submit' value='Generate PDF'>
      <p><small>Server expects JSON with 'html' field</small></p>
    </form>)
end
maze_post "/headless-generator/level6/" do |env|
  content_input = env.params.body["content"]?.to_s
  content_type = env.request.headers["Content-Type"]? || "application/x-www-form-urlencoded"

  # Try to parse as JSON
  html_output = ""
  format_detected = "unknown"

  begin
    json_data = JSON.parse(content_input)
    if json_data["html"]?
      html_output = json_data["html"].as_s
      format_detected = "json"
    end
  rescue
    # If JSON parsing fails, treat as raw HTML
    html_output = content_input
    format_detected = "html"
  end

  rendered_output = %(<div class="pdf-preview">
    <h3>PDF Generation Simulation</h3>
    <p>Content-Type: <code>#{HTML.escape(content_type)}</code></p>
    <p>Format detected: <strong>#{format_detected}</strong></p>
    <div class="rendered-content">
      #{html_output}
    </div>
    <p><em>Bypass hint: Send raw HTML with Content-Type: application/json header, or use polyglot payload</em></p>
  </div>)

  rendered_output
end
