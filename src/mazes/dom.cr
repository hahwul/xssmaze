def load_dom
    Xssmaze.push("dom-level1", "/dom/level1/","dom write")
    get "/dom/level1/" do |env|
        "<script>
            document.write(decodeURI(location.href))
        </script>"
    end

    Xssmaze.push("dom-level2", "/dom/level2/","dom write")
    get "/dom/level2/" do |env|
        "<script>
            document.write(decodeURI(location.hash))
        </script>"
    end

    Xssmaze.push("dom-level3", "/dom/level3/","redirect")
    get "/dom/level3/" do |env|
        "<script>
            document.location.href = location.hash.replace('#','')
        </script>"
    end
end