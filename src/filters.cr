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
end
