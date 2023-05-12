require "base64"

def load_decode
  Xssmaze.push("decode-level1", "/decode/level1/?query=a", "base64 decode")
  get "/decode/level1/" do |env|
    begin
      Base64.decode_string(env.params.query["query"])
    rescue
      "Decode Error"
    end
  end

  Xssmaze.push("decode-level2", "/decode/level2/?query=a", "url decode")
  get "/decode/level2/" do |env|
    begin
      if env.params.query["query"].includes?("<")
        "Detect Special Charactor"
      else
        URI.decode(env.params.query["query"])
      end
    rescue
      "Decode Error"
    end
  end

  Xssmaze.push("decode-level3", "/decode/level3/?query=a", "double url decode")
  get "/decode/level3/" do |env|
    data = URI.decode(env.params.query["query"])
    begin
      if data.includes?("<")
        "Detect Special Charactor"
      else
        URI.decode(data)
      end
    rescue
      "Decode Error"
    end
  end
end
