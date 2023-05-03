require "base64"

def load_encode
    Xssmaze.push("encode-level1", "/encode/level1/?query=a","no escape")
    get "/encode/level1/" do |env|
        begin
            Base64.decode_string(env.params.query["query"])
        rescue 
            "Decode Error"
        end
    end
end