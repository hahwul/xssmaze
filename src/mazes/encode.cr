require "base64"

def load_encode
    Xssmaze.push("encode-level1", "/encode/level1/?query=a","base64 encode")
    get "/encode/level1/" do |env|
        begin
            Base64.decode_string(env.params.query["query"])
        rescue 
            "Decode Error"
        end
    end

    Xssmaze.push("encode-level2", "/encode/level2/?query=a","url encode")
    get "/encode/level2/" do |env|
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

    Xssmaze.push("encode-level3", "/encode/level3/?query=a","double url encode")
    get "/encode/level3/" do |env|
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