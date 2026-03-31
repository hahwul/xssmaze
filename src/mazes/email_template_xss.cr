def load_email_template_xss
  # Level 1: Welcome email - raw reflection in table cell h2
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("email-template-level1", "/email-template/level1/?query=a", "welcome email raw reflection in table cell")
  maze_get "/email-template/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><table width=\"600\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:0 auto\"><tr><td style=\"padding:20px\"><h2>Welcome, #{query}!</h2></td></tr></table></body></html>"
  end

  # Level 2: Password reset link - reflection inside href attribute
  # Bypass: break out of href with ", e.g. "><script>alert(1)</script>
  Xssmaze.push("email-template-level2", "/email-template/level2/?query=a", "password reset link reflection in href attribute")
  maze_get "/email-template/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><table width=\"600\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:0 auto\"><tr><td style=\"padding:20px\"><p>Click <a href=\"https://example.com/reset?token=#{query}\">here</a> to reset your password.</p></td></tr></table></body></html>"
  end

  # Level 3: Order confirmation - raw reflection in product name table cell
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("email-template-level3", "/email-template/level3/?query=a", "order confirmation raw reflection in table cell")
  maze_get "/email-template/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><table width=\"600\" cellpadding=\"0\" cellspacing=\"0\" border=\"1\" style=\"margin:0 auto;border-collapse:collapse\"><thead><tr><th>Product</th><th>Price</th><th>Qty</th></tr></thead><tbody><tr><td>#{query}</td><td>$29.99</td><td>1</td></tr></tbody></table></body></html>"
  end

  # Level 4: Newsletter article - raw reflection in article heading
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("email-template-level4", "/email-template/level4/?query=a", "newsletter article heading raw reflection")
  maze_get "/email-template/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"article\" style=\"max-width:600px;margin:0 auto;padding:20px;border:1px solid #ddd\"><h3>#{query}</h3><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore.</p></div></body></html>"
  end

  # Level 5: Alert notification - raw reflection in colored table cell
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("email-template-level5", "/email-template/level5/?query=a", "alert notification raw reflection in colored cell")
  maze_get "/email-template/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><table width=\"600\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:0 auto\"><tr><td bgcolor=\"#ff0000\" style=\"color:#fff;padding:15px;font-weight:bold\">#{query}</td></tr></table></body></html>"
  end

  # Level 6: Invoice - raw reflection in description cell of complex table
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("email-template-level6", "/email-template/level6/?query=a", "invoice description cell raw reflection in complex table")
  maze_get "/email-template/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><table width=\"600\" cellpadding=\"5\" cellspacing=\"0\" border=\"1\" style=\"margin:0 auto;border-collapse:collapse\"><thead><tr><th>#</th><th>Description</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead><tbody><tr><td>1</td><td class=\"description\">#{query}</td><td>2</td><td>$15.00</td><td>$30.00</td></tr><tr><td>2</td><td class=\"description\">Standard Shipping</td><td>1</td><td>$5.00</td><td>$5.00</td></tr></tbody><tfoot><tr><td colspan=\"4\" style=\"text-align:right;font-weight:bold\">Grand Total:</td><td style=\"font-weight:bold\">$35.00</td></tr></tfoot></table></body></html>"
  end
end
