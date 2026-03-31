def load_custom_tag_xss
  # Level 1: Raw reflection inside a custom element
  # Bypass: inject arbitrary HTML since no escaping is applied
  # e.g. <script>alert(1)</script>
  Xssmaze.push("customtag-level1", "/customtag/level1/?query=a", "raw reflection in custom element")
  maze_get "/customtag/level1/" do |env|
    query = env.params.query["query"]

    "<html><body><custom-element>#{query}</custom-element></body></html>"
  end

  # Level 2: Reflection in data-value attribute of custom element
  # Bypass: break out of attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("customtag-level2", "/customtag/level2/?query=a", "reflection in custom element data-value attribute")
  maze_get "/customtag/level2/" do |env|
    query = env.params.query["query"]

    "<html><body><x-widget data-value=\"#{query}\">content</x-widget></body></html>"
  end

  # Level 3: Raw reflection inside div with is= custom element extension
  # Bypass: inject arbitrary HTML since no escaping is applied
  # e.g. <script>alert(1)</script>
  Xssmaze.push("customtag-level3", "/customtag/level3/?query=a", "raw reflection in customized built-in element (is= attribute)")
  maze_get "/customtag/level3/" do |env|
    query = env.params.query["query"]

    "<html><body><div is=\"custom-div\">#{query}</div></body></html>"
  end

  # Level 4: Reflection in slot name attribute
  # Bypass: break out of name attribute with " then inject new tag
  # e.g. "><script>alert(1)</script>
  Xssmaze.push("customtag-level4", "/customtag/level4/?query=a", "reflection in slot name attribute")
  maze_get "/customtag/level4/" do |env|
    query = env.params.query["query"]

    "<html><body><slot name=\"#{query}\">default</slot></body></html>"
  end

  # Level 5: Raw reflection inside template element
  # Template contents are inert in browser but visible in response source
  # Bypass: inject arbitrary HTML (detectable by response-body scanner)
  # e.g. <script>alert(1)</script>
  Xssmaze.push("customtag-level5", "/customtag/level5/?query=a", "raw reflection inside template element")
  maze_get "/customtag/level5/" do |env|
    query = env.params.query["query"]

    "<html><body><template id=\"tmpl\"><div>#{query}</div></template></body></html>"
  end

  # Level 6: Raw reflection inside output element
  # Bypass: inject arbitrary HTML since no escaping is applied
  # e.g. <script>alert(1)</script>
  Xssmaze.push("customtag-level6", "/customtag/level6/?query=a", "raw reflection in output element")
  maze_get "/customtag/level6/" do |env|
    query = env.params.query["query"]

    "<html><body><output name=\"result\">#{query}</output></body></html>"
  end
end
