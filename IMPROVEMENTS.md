# XSSMaze Improvement Plan

## Test Results (Dalfox v3 Detection)

Dalfox detected 50/104 challenges (48.1%). Below are observations and improvement suggestions for the maze itself.

---

## Improvements for Challenge Quality

### 1. DOM Challenges Need Query Parameter Reflection
**Priority: High**

DOM levels 1-3 use `location.hash` or `location.href` as the XSS source, with no server-side reflection. This makes them invisible to HTTP-based scanners. While this accurately represents real-world DOM XSS, it would be useful to have variants that also include server-side "hints" (e.g., the query param value appearing in an inline `<script>` as a variable assignment).

**Suggestion**: Add parallel DOM challenge variants where the JS source reads from a query parameter that also appears reflected in the response, giving scanners a chance to detect the sink via static analysis.

### 2. Add Difficulty Metadata to /map/json
**Priority: Medium**

The `/map/json` endpoint only returns paths. Adding metadata would make it more useful:
```json
{
  "endpoints": [
    {
      "path": "/basic/level1/?query=a",
      "category": "basic",
      "level": 1,
      "difficulty": "easy",
      "context": "html-body",
      "filters": [],
      "expected_vector": "tag-injection"
    }
  ]
}
```

### 3. Add Solution Verification Endpoint
**Priority: Medium**

Add an endpoint like `/verify?url=<encoded-url>` that loads the URL in a sandboxed context and checks if `alert()` was called. This enables automated scoring.

### 4. Add Scoring System
**Priority: Low**

Track which challenges a scanner solves and provide a score:
- `/score/start` - Start a new scoring session
- `/score/status` - Get current score
- Each challenge hit with a working XSS payload increments the score

### 5. Missing Challenge Categories
**Priority: Medium**

Categories that could be added to increase coverage testing:
- **CRLF Injection**: Header injection leading to XSS
- **File Upload XSS**: SVG/HTML file upload
- **Polyglot Payloads**: Single input that triggers in multiple contexts
- **Mutation XSS (mXSS)**: Payloads that mutate through DOMParser
- **Prototype Pollution**: Leading to XSS via gadgets
- **Import Maps**: Module import-based XSS
- **Shadow DOM**: XSS within shadow DOM boundaries

### 6. Redirect Challenges Should Allow Scanner Detection
**Priority: Medium**

Redirect levels immediately 302-redirect without body content. Scanners that don't follow redirects or check Location headers will miss these entirely. Consider adding a response body with the redirect URL reflected before the redirect, or providing a `?noredirect=1` debug mode.

### 7. POST Challenges Need Form Discovery
**Priority: Low**

POST levels have no HTML form on the GET response. Scanners must be explicitly told to POST. Consider adding an HTML form on the GET response so scanners can discover the POST action automatically.

### 8. JSON Challenges Content-Type
**Priority: Low**

JSON levels 1-3 return `application/json` content-type, which causes many scanners to skip them. Consider adding a variant with `text/html` content-type for JSONP callbacks, which is a more realistic attack scenario.

---

## Bug Fixes

### 1. Basic Level 3 Incorrect Escape
Level 3 maps `'` to `&quot;` instead of `&#39;` or `&apos;`. This is technically a bug in the escape implementation (should be `&#39;`), though it still demonstrates a bypass scenario.

### 2. Inconsistent Trailing Slash Handling
Some endpoints require trailing slash, others don't. The route registration handles both, but the `/map/json` listing is inconsistent about which form is canonical.

---

## New Challenge Ideas

### Phase 1: Quick Additions
1. **Attribute injection with tab/newline separators** (e.g., inject event handlers using `%09` or `%0a` instead of space)
2. **Nested encoding challenges** (triple URL encode, mixed encoding)
3. **HTML comment injection** (`<!-- -->` context)
4. **CDATA injection** in XML/XHTML context
5. **Meta tag refresh XSS** (`<meta http-equiv="refresh" content="0;url=javascript:alert(1)">`)

### Phase 2: Advanced Additions
1. **DOM clobbering** with named access on window
2. **Prototype pollution to XSS** chain
3. **Service Worker registration** from user-controlled URL
4. **Import map injection** for module hijacking
5. **Trusted Types policy bypass** with complex policy
