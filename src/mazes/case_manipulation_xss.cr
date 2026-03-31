def load_case_manipulation_xss
  # Level 1: Server lowercases only tag names (replaces <[A-Z]+ with lowercase)
  # but not attributes - standard lowercase payloads work fine
  Xssmaze.push("casemanip-level1", "/casemanip/level1/?query=a", "lowercase tag names only, attributes untouched")
  maze_get "/casemanip/level1/" do |env|
    query = env.params.query["query"]
    # Lowercase only the tag name portion: <TAG -> <tag
    result = query.gsub(/<([A-Za-z]+)/) do |match|
      tag = $1
      "<#{tag.downcase}"
    end

    "<html><body>#{result}</body></html>"
  end

  # Level 2: Server capitalizes first letter of input, rest unchanged
  # <img src=x onerror=alert(1)> becomes <Img src=x onerror=alert(1)> which is valid HTML
  Xssmaze.push("casemanip-level2", "/casemanip/level2/?query=a", "capitalize first letter only, HTML still valid")
  maze_get "/casemanip/level2/" do |env|
    query = env.params.query["query"]
    result = if query.size > 0
               query[0].upcase + query[1..]
             else
               query
             end

    "<html><body>#{result}</body></html>"
  end

  # Level 3: Server swaps case of all alpha chars
  # HTML is case-insensitive so swapped tags still work
  Xssmaze.push("casemanip-level3", "/casemanip/level3/?query=a", "swap case of all alpha chars, HTML case-insensitive")
  maze_get "/casemanip/level3/" do |env|
    query = env.params.query["query"]
    result = query.chars.map do |c|
      if c.uppercase?
        c.downcase
      elsif c.lowercase?
        c.upcase
      else
        c
      end
    end.join

    "<html><body>#{result}</body></html>"
  end

  # Level 4: Server ROT13 encodes alpha chars in displayed output
  # BUT also reflects original unmodified query in a hidden input - exploitable
  Xssmaze.push("casemanip-level4", "/casemanip/level4/?query=a", "ROT13 display but raw reflection in hidden input")
  maze_get "/casemanip/level4/" do |env|
    query = env.params.query["query"]
    rot13 = query.chars.map do |c|
      if c >= 'a' && c <= 'z'
        ((((c.ord - 'a'.ord) + 13) % 26) + 'a'.ord).chr
      elsif c >= 'A' && c <= 'Z'
        ((((c.ord - 'A'.ord) + 13) % 26) + 'A'.ord).chr
      else
        c
      end
    end.join

    "<html><body><p>#{rot13}</p><input type=\"hidden\" value=\"#{query}\"></body></html>"
  end

  # Level 5: Server strips uppercase letters only, leaves lowercase and everything else
  # Use all-lowercase payload: <img src=x onerror=alert(1)>
  Xssmaze.push("casemanip-level5", "/casemanip/level5/?query=a", "strip uppercase letters only, lowercase payloads work")
  maze_get "/casemanip/level5/" do |env|
    query = env.params.query["query"]
    result = query.gsub(/[A-Z]/, "")

    "<html><body>#{result}</body></html>"
  end

  # Level 6: Server titlecases words (first letter of each word uppercase)
  # HTML tags still work since they are case-insensitive
  Xssmaze.push("casemanip-level6", "/casemanip/level6/?query=a", "titlecase words, HTML case-insensitive")
  maze_get "/casemanip/level6/" do |env|
    query = env.params.query["query"]
    result = query.split(" ").map do |word|
      if word.size > 0
        word[0].upcase + word[1..]
      else
        word
      end
    end.join(" ")

    "<html><body>#{result}</body></html>"
  end
end
