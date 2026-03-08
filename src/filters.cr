module Filters
  def self.strip_angles(str : String) : String
    str.gsub("<", "").gsub(">", "")
  end

  def self.escape_quotes(str : String) : String
    str.gsub("\"", "&quot;").gsub("'", "&quot;")
  end

  def self.escape_double_quote(str : String) : String
    str.gsub("\"", "&quot;")
  end

  def self.escape_single_quote(str : String) : String
    str.gsub("'", "&quot;")
  end

  def self.strip_parens(str : String) : String
    str.gsub("(", "").gsub(")", "")
  end

  def self.strip_spaces(str : String) : String
    str.gsub(" ", "")
  end

  # Case-insensitive keyword removal (bypassable via mixed case encoding)
  def self.strip_keyword_ci(str : String, keyword : String) : String
    str.gsub(/#{Regex.escape(keyword)}/i, "")
  end

  # Recursive keyword removal (handles double-insertion like <scr<script>ipt>)
  def self.strip_keyword_recursive(str : String, keyword : String) : String
    result = str
    loop do
      replaced = result.gsub(/#{Regex.escape(keyword)}/i, "")
      break if replaced == result
      result = replaced
    end
    result
  end

  # Tag blacklist filter (removes specific tags but allows others)
  def self.strip_tags(str : String, tags : Array(String)) : String
    result = str
    tags.each do |tag|
      result = result.gsub(/<\/?#{Regex.escape(tag)}[^>]*>/i, "")
    end
    result
  end

  # Whitelist filter (removes all tags except allowed ones)
  def self.whitelist_tags(str : String, allowed : Array(String)) : String
    pattern = allowed.map { |tag| Regex.escape(tag) }.join("|")
    str.gsub(/<\/?(?!(?:#{pattern})\b)[a-z][a-z0-9]*[^>]*>/i, "")
  end

  # Strip event handlers (onclick, onerror, etc.)
  def self.strip_event_handlers(str : String) : String
    str.gsub(/\bon\w+\s*=/i, "")
  end

  # Strip javascript: protocol
  def self.strip_js_protocol(str : String) : String
    str.gsub(/javascript\s*:/i, "")
  end

  # HTML entity encode angle brackets (allows attribute-context bypass)
  def self.encode_angles(str : String) : String
    str.gsub("<", "&lt;").gsub(">", "&gt;")
  end
end
