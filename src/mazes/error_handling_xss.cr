def load_error_handling_xss
  # Level 1: Try-catch style error boundary with raw reflection
  Xssmaze.push("errhandling-level1", "/errhandling/level1/?query=a", "error boundary with raw reflection in error message")
  maze_get "/errhandling/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 1</h1>
    <div class=\"error-boundary\">
      <h2>Something went wrong</h2>
      <p class=\"error-message\">#{query}</p>
    </div>
    </body></html>"
  end

  # Level 2: Stack trace style with query reflected in the 3rd frame
  Xssmaze.push("errhandling-level2", "/errhandling/level2/?query=a", "stack trace with raw reflection in third frame")
  maze_get "/errhandling/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 2</h1>
    <div class=\"stack-trace\">
      <h2>Unhandled Exception</h2>
      <div class=\"stack-frame\">at Object.main (app.js:1:1)</div>
      <div class=\"stack-frame\">at Module._compile (module.js:653:30)</div>
      <div class=\"stack-frame\">at processInput (#{query})</div>
      <div class=\"stack-frame\">at Layer.handle (router.js:174:5)</div>
      <div class=\"stack-frame\">at next (route.js:137:13)</div>
    </div>
    </body></html>"
  end

  # Level 3: Form validation error with raw reflection
  Xssmaze.push("errhandling-level3", "/errhandling/level3/?query=a", "form validation error with raw reflection in alert span")
  maze_get "/errhandling/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 3</h1>
    <form>
      <label for=\"email\">Email:</label>
      <input type=\"text\" id=\"email\" value=\"\">
      <span class=\"field-error\" role=\"alert\">#{query}</span>
      <button type=\"submit\">Submit</button>
    </form>
    </body></html>"
  end

  # Level 4: API error response in pre block (served as text/html)
  Xssmaze.push("errhandling-level4", "/errhandling/level4/?query=a", "API error response in pre tag with raw JSON-like reflection")
  maze_get "/errhandling/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 4</h1>
    <h2>API Error Response</h2>
    <pre class=\"api-error\">{\"code\":400,\"message\":\"#{query}\"}</pre>
    </body></html>"
  end

  # Level 5: Permission denied page with raw reflection
  Xssmaze.push("errhandling-level5", "/errhandling/level5/?query=a", "permission denied page with raw reflection in resource path")
  maze_get "/errhandling/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 5</h1>
    <div class=\"denied\">
      <h2>Access Denied</h2>
      <p>You do not have permission to access this resource.</p>
      <p>Resource: #{query}</p>
    </div>
    </body></html>"
  end

  # Level 6: Rate limit page with raw reflection
  Xssmaze.push("errhandling-level6", "/errhandling/level6/?query=a", "rate limit page with raw reflection in IP/source field")
  maze_get "/errhandling/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Error Handling XSS Level 6</h1>
    <div class=\"rate-limit\">
      <h2>429 Too Many Requests</h2>
      <p>Too many requests from #{query}</p>
      <p>Please try again later.</p>
    </div>
    </body></html>"
  end
end
