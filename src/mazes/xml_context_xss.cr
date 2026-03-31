def load_xml_context_xss
  # Level 1: XHTML page with query in <p> element, served as text/html - standard injection
  Xssmaze.push("xmlctx-level1", "/xmlctx/level1/?query=a", "XHTML page with query in p element (text/html)")
  maze_get "/xmlctx/level1/" do |env|
    query = env.params.query["query"]

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head><title>XHTML Page</title></head>
<body><p>#{query}</p></body>
</html>"
  end

  # Level 2: XML-like CDATA section inside script, served as text/html - close CDATA and script
  Xssmaze.push("xmlctx-level2", "/xmlctx/level2/?query=a", "query in CDATA section inside script tag")
  maze_get "/xmlctx/level2/" do |env|
    query = env.params.query["query"]

    "<html><head></head><body>
<script type=\"text/javascript\">
//<![CDATA[
var data = \"#{query}\";
//]]>
</script>
<p>Content</p></body></html>"
  end

  # Level 3: Query in XML processing instruction, served as text/html - inject HTML after
  Xssmaze.push("xmlctx-level3", "/xmlctx/level3/?query=a", "query in XML processing instruction context")
  maze_get "/xmlctx/level3/" do |env|
    query = env.params.query["query"]

    "<?xml version=\"1.0\" #{query} ?>
<html><head><title>XML PI</title></head>
<body><p>Content</p></body></html>"
  end

  # Level 4: Query in <xmp> tag (deprecated but still parsed) - break out with </xmp>
  Xssmaze.push("xmlctx-level4", "/xmlctx/level4/?query=a", "query in deprecated xmp tag")
  maze_get "/xmlctx/level4/" do |env|
    query = env.params.query["query"]

    "<html><head><title>XMP Context</title></head>
<body><xmp>#{query}</xmp></body></html>"
  end

  # Level 5: Query in <listing> tag (deprecated) - break out with </listing>
  Xssmaze.push("xmlctx-level5", "/xmlctx/level5/?query=a", "query in deprecated listing tag")
  maze_get "/xmlctx/level5/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Listing Context</title></head>
<body><listing>#{query}</listing></body></html>"
  end

  # Level 6: Query reflected BEFORE plaintext tag (plaintext disables all parsing after it)
  Xssmaze.push("xmlctx-level6", "/xmlctx/level6/?query=a", "query reflected before plaintext tag")
  maze_get "/xmlctx/level6/" do |env|
    query = env.params.query["query"]

    "<html><head><title>Plaintext Context</title></head>
<body><div>#{query}</div><plaintext>This text is rendered as plain text and no HTML is parsed after this tag.</plaintext></body></html>"
  end
end
