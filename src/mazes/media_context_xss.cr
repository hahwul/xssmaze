def load_media_context_xss
  # Level 1: Reflected in <video src="QUERY">
  Xssmaze.push("mediacontext-level1", "/mediacontext/level1/?query=a", "reflection in video src attribute")
  maze_get "/mediacontext/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 1</h1>
    <video src=\"#{query}\" controls>Your browser does not support video.</video>
    </body></html>"
  end

  # Level 2: Reflected in <audio src="QUERY">
  Xssmaze.push("mediacontext-level2", "/mediacontext/level2/?query=a", "reflection in audio src attribute")
  maze_get "/mediacontext/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 2</h1>
    <audio src=\"#{query}\" controls>Your browser does not support audio.</audio>
    </body></html>"
  end

  # Level 3: Reflected in <source src="QUERY"> inside a <video>
  Xssmaze.push("mediacontext-level3", "/mediacontext/level3/?query=a", "reflection in source src attribute inside video")
  maze_get "/mediacontext/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 3</h1>
    <video controls><source src=\"#{query}\" type=\"video/mp4\">Your browser does not support video.</video>
    </body></html>"
  end

  # Level 4: Reflected in <embed src="QUERY">
  Xssmaze.push("mediacontext-level4", "/mediacontext/level4/?query=a", "reflection in embed src attribute")
  maze_get "/mediacontext/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 4</h1>
    <embed src=\"#{query}\" type=\"application/x-shockwave-flash\">
    </body></html>"
  end

  # Level 5: Reflected in <track src="QUERY"> inside a <video>
  Xssmaze.push("mediacontext-level5", "/mediacontext/level5/?query=a", "reflection in track src attribute inside video")
  maze_get "/mediacontext/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 5</h1>
    <video controls><source src=\"/video.mp4\" type=\"video/mp4\"><track src=\"#{query}\" kind=\"subtitles\" srclang=\"en\"></video>
    </body></html>"
  end

  # Level 6: Reflected in <img alt="QUERY">
  Xssmaze.push("mediacontext-level6", "/mediacontext/level6/?query=a", "reflection in img alt attribute")
  maze_get "/mediacontext/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Media Context XSS Level 6</h1>
    <img src=\"/image.png\" alt=\"#{query}\">
    </body></html>"
  end
end
