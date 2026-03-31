def load_cms_pattern_xss
  # Level 1: WordPress post title - raw reflection in entry-title h1
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level1", "/cmspattern/level1/?query=a", "WordPress post title raw reflection")
  maze_get "/cmspattern/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><h1 class=\"entry-title\">#{query}</h1></body></html>"
  end

  # Level 2: WordPress widget title - raw reflection in widget-title h3
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level2", "/cmspattern/level2/?query=a", "WordPress widget title raw reflection")
  maze_get "/cmspattern/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"widget\"><h3 class=\"widget-title\">#{query}</h3></div></body></html>"
  end

  # Level 3: Drupal field body - raw reflection in field paragraph
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level3", "/cmspattern/level3/?query=a", "Drupal field body raw reflection")
  maze_get "/cmspattern/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"field field--name-body\"><p>#{query}</p></div></body></html>"
  end

  # Level 4: Joomla module - raw reflection in module heading
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level4", "/cmspattern/level4/?query=a", "Joomla module heading raw reflection")
  maze_get "/cmspattern/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"moduletable\"><h3>#{query}</h3><div class=\"module-body\">content</div></div></body></html>"
  end

  # Level 5: Ghost blog excerpt - raw reflection in post-card-excerpt
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level5", "/cmspattern/level5/?query=a", "Ghost blog excerpt raw reflection")
  maze_get "/cmspattern/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><p class=\"post-card-excerpt\">#{query}</p></body></html>"
  end

  # Level 6: Medium-style article section - raw reflection in nested article content
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("cmspattern-level6", "/cmspattern/level6/?query=a", "Medium-style article content raw reflection")
  maze_get "/cmspattern/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><article><section><div class=\"section-content\"><p>#{query}</p></div></section></article></body></html>"
  end
end
