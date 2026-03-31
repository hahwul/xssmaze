def load_ecommerce_xss
  # Level 1: Product name - raw reflection in product-title h1 with itemprop
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level1", "/ecommerce/level1/?query=a", "product name raw reflection with itemprop")
  maze_get "/ecommerce/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><h1 class=\"product-title\" itemprop=\"name\">#{query}</h1></body></html>"
  end

  # Level 2: Product price context - raw reflection inside price span
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level2", "/ecommerce/level2/?query=a", "product price raw reflection")
  maze_get "/ecommerce/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><span class=\"price\">$#{query}</span></body></html>"
  end

  # Level 3: Search filter tag - raw reflection in filter tag span
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level3", "/ecommerce/level3/?query=a", "search filter tag raw reflection")
  maze_get "/ecommerce/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"filter-tag\"><span>#{query}</span><a href=\"#\" class=\"remove\">x</a></div></body></html>"
  end

  # Level 4: Cart item name - raw reflection in table cell
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level4", "/ecommerce/level4/?query=a", "cart item name in table cell raw reflection")
  maze_get "/ecommerce/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><table><thead><tr><th>Item</th><th>Qty</th><th>Price</th></tr></thead><tbody><tr><td class=\"cart-item-name\">#{query}</td><td>1</td><td>$9.99</td></tr></tbody></table></body></html>"
  end

  # Level 5: Review content - raw reflection in review body paragraph
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level5", "/ecommerce/level5/?query=a", "review body raw reflection")
  maze_get "/ecommerce/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"review-body\"><p>#{query}</p></div></body></html>"
  end

  # Level 6: Breadcrumb trail - raw reflection in active breadcrumb item
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("ecommerce-level6", "/ecommerce/level6/?query=a", "breadcrumb active item raw reflection")
  maze_get "/ecommerce/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><ol class=\"breadcrumb\"><li>Home</li><li>Products</li><li class=\"active\">#{query}</li></ol></body></html>"
  end
end
