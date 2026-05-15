# Stored XSS shapes scanners can actually exercise. The lab keeps a
# small in-memory store per level so that POSTs persist for the
# duration of the process; each POST handler also reflects the saved
# value in the same response, so scanners that don't follow up with a
# separate GET still detect the issue. Patterns are picked from
# recurring bug-bounty reports (comment systems, profile bios, product
# reviews, support tickets, admin notes).
def load_stored_pattern_xss
  store = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }
  single = Hash(String, String).new("")

  # Level 1: comment system storing into attribute context
  # Real shape: comment body escaped for body display but reused
  # *raw* inside an attribute (`title=`, `data-*`). Reviews-style.
  Xssmaze.push("storedpat-level1", "/storedpat/level1/", "comment stored in body (escaped) + title attr (raw)", "POST")
  maze_get "/storedpat/level1/" do |_|
    items = store["lvl1"].map do |c|
      "<li title=\"#{c}\">#{Xssmaze.html_escape(c)}</li>"
    end.join
    "<!doctype html><html><body>
    <h1>Comments</h1>
    <form method='post'><input name='body' value='hi'><button>Post</button></form>
    <ul>#{items}</ul>
    </body></html>"
  end
  maze_post "/storedpat/level1/" do |env|
    body = env.params.body.fetch("body", "")
    store["lvl1"] << body
    items = store["lvl1"].map do |c|
      "<li title=\"#{c}\">#{Xssmaze.html_escape(c)}</li>"
    end.join
    "<!doctype html><html><body>
    <h1>Comments</h1>
    <form method='post'><input name='body' value='hi'><button>Post</button></form>
    <ul>#{items}</ul>
    </body></html>"
  end

  # Level 2: profile bio rendered through a tiny markdown subset
  # `**bold**` and `*italic*` are converted; raw HTML passes through.
  # Real shape: GitHub README / Discourse cooked content, where the
  # renderer trusts the saved markdown.
  Xssmaze.push("storedpat-level2", "/storedpat/level2/", "profile bio markdown render (HTML pass-through)", "POST")
  maze_get "/storedpat/level2/" do |_|
    bio = single["lvl2"]
    rendered = bio.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{$1}</strong>" }
                  .gsub(/\*([^*]+)\*/) { "<em>#{$1}</em>" }
    "<!doctype html><html><body>
    <h1>Profile</h1>
    <form method='post'><textarea name='bio'>about me</textarea><button>Save</button></form>
    <section class='bio'>#{rendered}</section>
    </body></html>"
  end
  maze_post "/storedpat/level2/" do |env|
    bio = env.params.body.fetch("bio", "")
    single["lvl2"] = bio
    rendered = bio.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{$1}</strong>" }
                  .gsub(/\*([^*]+)\*/) { "<em>#{$1}</em>" }
    "<!doctype html><html><body>
    <h1>Profile</h1>
    <form method='post'><textarea name='bio'>about me</textarea><button>Save</button></form>
    <section class='bio'>#{rendered}</section>
    </body></html>"
  end

  # Level 3: product review with rating reflected into <meta> content
  # Real shape: e-commerce review form. Review body lands raw in
  # `<meta property="og:description">` content, which is attribute
  # context — escapes quotes only.
  Xssmaze.push("storedpat-level3", "/storedpat/level3/", "product review stored into <meta og:description>", "POST")
  maze_get "/storedpat/level3/" do |_|
    last = single["lvl3"]
    "<!doctype html><html><head>
    <meta property=\"og:description\" content=\"#{last}\">
    </head><body>
    <h1>Reviews</h1>
    <form method='post'><input name='review' value='good'><button>Send</button></form>
    <p>Latest: #{Xssmaze.html_escape(last)}</p>
    </body></html>"
  end
  maze_post "/storedpat/level3/" do |env|
    review = env.params.body.fetch("review", "")
    single["lvl3"] = review
    "<!doctype html><html><head>
    <meta property=\"og:description\" content=\"#{review}\">
    </head><body>
    <h1>Reviews</h1>
    <form method='post'><input name='review' value='good'><button>Send</button></form>
    <p>Latest: #{Xssmaze.html_escape(review)}</p>
    </body></html>"
  end

  # Level 4: chat message recent list (same-request preview + GET list)
  # Real shape: support chat / live discussion thread. New message is
  # appended and the entire thread re-rendered, raw.
  Xssmaze.push("storedpat-level4", "/storedpat/level4/", "chat message thread (raw render)", "POST")
  maze_get "/storedpat/level4/" do |_|
    msgs = store["lvl4"].map { |m| "<div class='msg'>#{m}</div>" }.join
    "<!doctype html><html><body>
    <h1>Chat</h1>
    <form method='post'><input name='msg' value='hello'><button>Send</button></form>
    <section id='thread'>#{msgs}</section>
    </body></html>"
  end
  maze_post "/storedpat/level4/" do |env|
    msg = env.params.body.fetch("msg", "")
    store["lvl4"] << msg
    msgs = store["lvl4"].map { |m| "<div class='msg'>#{m}</div>" }.join
    "<!doctype html><html><body>
    <h1>Chat</h1>
    <form method='post'><input name='msg' value='hello'><button>Send</button></form>
    <section id='thread'>#{msgs}</section>
    </body></html>"
  end

  # Level 5: support ticket subject stored into <title> on view page
  # Real shape: Zendesk-style ticket. Subject lands in `<title>` and
  # in `<h1>` on the ticket-view page (a separate GET). Same-request
  # response also shows the stored subject for scanner detection.
  Xssmaze.push("storedpat-level5", "/storedpat/level5/", "ticket subject stored into <title> and <h1>", "POST")
  maze_get "/storedpat/level5/" do |_|
    subj = single["lvl5"]
    "<!doctype html><html><head>
    <title>Ticket — #{subj}</title>
    </head><body>
    <h1>#{subj}</h1>
    <form method='post'><input name='subject' value='help'><button>Open</button></form>
    </body></html>"
  end
  maze_post "/storedpat/level5/" do |env|
    subj = env.params.body.fetch("subject", "")
    single["lvl5"] = subj
    "<!doctype html><html><head>
    <title>Ticket — #{subj}</title>
    </head><body>
    <h1>#{subj}</h1>
    <form method='post'><input name='subject' value='help'><button>Open</button></form>
    </body></html>"
  end

  # Level 6: admin note stored as JSON, rendered to DOM via innerHTML
  # Real shape: admin dashboard fetches notes API and pastes the
  # `text` field into the DOM. POST stores; GET serves the API; the
  # HTML page wires it up.
  Xssmaze.push("storedpat-level6", "/storedpat/level6/", "admin note: POST stored, fetched JSON → innerHTML", "POST")
  maze_get "/storedpat/level6/" do |_|
    "<!doctype html><html><body>
    <h1>Admin notes</h1>
    <form method='post'><input name='note' value='ok'><button>Save</button></form>
    <div id='note'></div>
    <script>
      fetch('/storedpat/level6/api').then(r=>r.json()).then(d=>{
        document.getElementById('note').innerHTML = d.note;
      });
    </script>
    </body></html>"
  end
  maze_post "/storedpat/level6/" do |env|
    note = env.params.body.fetch("note", "")
    single["lvl6"] = note
    "<!doctype html><html><body>
    <h1>Admin notes</h1>
    <form method='post'><input name='note' value='ok'><button>Save</button></form>
    <div id='note'></div>
    <script>
      fetch('/storedpat/level6/api').then(r=>r.json()).then(d=>{
        document.getElementById('note').innerHTML = d.note;
      });
    </script>
    </body></html>"
  end
  get "/storedpat/level6/api" do |env|
    env.response.content_type = "application/json"
    {note: single["lvl6"]}.to_json
  end
end
