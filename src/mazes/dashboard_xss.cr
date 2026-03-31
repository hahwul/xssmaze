def load_dashboard_xss
  # Level 1: Dashboard card title - raw reflection in card-header div
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("dashboard-level1", "/dashboard/level1/?query=a", "dashboard card header raw reflection")
  maze_get "/dashboard/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"card\"><div class=\"card-header\">#{query}</div></div></body></html>"
  end

  # Level 2: Admin table cell - dual reflection in title attribute AND body
  # Bypass: break out of title attribute with " or inject in body directly
  # e.g. "><script>alert(1)</script> or just <script>alert(1)</script>
  Xssmaze.push("dashboard-level2", "/dashboard/level2/?query=a", "admin table cell dual reflection (attr + body)")
  maze_get "/dashboard/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><table><tr><td class=\"text-truncate\" title=\"#{query}\">#{query}</td></tr></table></body></html>"
  end

  # Level 3: Notification alert - raw reflection in alert div
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("dashboard-level3", "/dashboard/level3/?query=a", "notification alert raw reflection")
  maze_get "/dashboard/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"alert alert-info\" role=\"alert\">#{query}</div></body></html>"
  end

  # Level 4: Sidebar menu item - raw reflection in nav-link anchor
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("dashboard-level4", "/dashboard/level4/?query=a", "sidebar nav-link raw reflection")
  maze_get "/dashboard/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><ul class=\"nav\"><li class=\"nav-item\"><a class=\"nav-link\" href=\"#\">#{query}</a></li></ul></body></html>"
  end

  # Level 5: Modal body content - raw reflection in modal-body paragraph
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("dashboard-level5", "/dashboard/level5/?query=a", "modal body raw reflection")
  maze_get "/dashboard/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"modal\"><div class=\"modal-dialog\"><div class=\"modal-content\"><div class=\"modal-body\"><p>#{query}</p></div></div></div></div></body></html>"
  end

  # Level 6: Status badge - raw reflection in badge span
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("dashboard-level6", "/dashboard/level6/?query=a", "status badge raw reflection")
  maze_get "/dashboard/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><span class=\"badge badge-primary\">#{query}</span></body></html>"
  end
end
