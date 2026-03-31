def load_social_media_xss
  # Level 1: Tweet/post content - raw reflection in tweet text paragraph
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("social-media-level1", "/social-media/level1/?query=a", "tweet/post content raw reflection")
  maze_get "/social-media/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"tweet\" style=\"max-width:500px;border:1px solid #ccd6dd;border-radius:12px;padding:12px\"><div class=\"tweet-header\"><strong>User</strong> <span style=\"color:#657786\">@user - 1h</span></div><div class=\"tweet-text\"><p>#{query}</p></div></div></body></html>"
  end

  # Level 2: Username mention - raw reflection in mention link text
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("social-media-level2", "/social-media/level2/?query=a", "username mention raw reflection in link text")
  maze_get "/social-media/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"post\" style=\"padding:10px\"><p>Check out this post by <a href=\"/user/profile\" class=\"mention\" style=\"color:#1da1f2;text-decoration:none\">@#{query}</a> about security.</p></div></body></html>"
  end

  # Level 3: Hashtag - dual reflection in href attribute AND link text
  # Bypass: break out of href with ", e.g. "><script>alert(1)</script>
  # or inject directly in the text portion
  Xssmaze.push("social-media-level3", "/social-media/level3/?query=a", "hashtag dual reflection in href and link text")
  maze_get "/social-media/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"post\" style=\"padding:10px\"><p>Trending now: <a href=\"/tag/#{query}\" class=\"hashtag\" style=\"color:#1da1f2;text-decoration:none\">##{query}</a></p></div></body></html>"
  end

  # Level 4: Bio/description - raw reflection in bio paragraph
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("social-media-level4", "/social-media/level4/?query=a", "user bio/description raw reflection")
  maze_get "/social-media/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"profile-card\" style=\"max-width:400px;border:1px solid #e1e8ed;border-radius:12px;padding:16px\"><div class=\"profile-header\"><img src=\"/avatar.png\" alt=\"avatar\" width=\"48\" height=\"48\" style=\"border-radius:50%\"><h3 style=\"margin:8px 0 4px\">John Doe</h3><span style=\"color:#657786\">@johndoe</span></div><p class=\"bio-text\" style=\"margin-top:12px\">#{query}</p></div></body></html>"
  end

  # Level 5: Comment reply - raw reflection in reply text span
  # Bypass: direct HTML injection, e.g. <script>alert(1)</script>
  Xssmaze.push("social-media-level5", "/social-media/level5/?query=a", "comment reply raw reflection in text span")
  maze_get "/social-media/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"comment-thread\" style=\"max-width:500px;padding:10px\"><div class=\"original-comment\" style=\"padding:8px;border-left:3px solid #ccc;margin-bottom:10px\"><span class=\"author\" style=\"font-weight:bold\">OriginalPoster</span>: <span>What do you think?</span></div><div class=\"reply\" style=\"padding:8px;margin-left:20px;border-left:3px solid #1da1f2\"><span class=\"author\" style=\"font-weight:bold\">user</span>: <span class=\"text\">#{query}</span></div></div></body></html>"
  end

  # Level 6: Share link - reflection inside href attribute of share button
  # Bypass: break out of href with ", e.g. "><script>alert(1)</script>
  Xssmaze.push("social-media-level6", "/social-media/level6/?query=a", "share link reflection in href attribute")
  maze_get "/social-media/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><div class=\"share-panel\" style=\"max-width:400px;padding:12px;border:1px solid #e1e8ed;border-radius:8px\"><p style=\"margin-bottom:10px\">Share this post:</p><a href=\"https://share.example.com/?text=#{query}\" class=\"share-btn\" style=\"display:inline-block;padding:8px 16px;background:#1da1f2;color:#fff;border-radius:4px;text-decoration:none\">Share</a></div></body></html>"
  end
end
