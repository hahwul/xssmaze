def load_dom
  Xssmaze.push("dom-level1", "/dom/level1/", "dom write (location.href)")
  get "/dom/level1/" do |_|
    "<script>
            document.write(decodeURI(location.href))
        </script>"
  end

  Xssmaze.push("dom-level2", "/dom/level2/", "dom write (location.hash)")
  get "/dom/level2/" do |_|
    "<script>
            document.write(decodeURI(location.hash))
        </script>"
  end

  Xssmaze.push("dom-level3", "/dom/level3/", "redirect (location.hash)")
  get "/dom/level3/" do |_|
    "<script>
            document.location.href = location.hash.replace('#','')
        </script>"
  end

  Xssmaze.push("dom-level4", "/dom/level4/", "dom write (query param)")
  get "/dom/level4/" do |_|
    "<script>
            const urlParams = new URL(location.href).searchParams;
            const query = urlParams.get('query');
            document.write(query)
        </script>"
  end

  Xssmaze.push("dom-level5", "/dom/level5/", "dom write (query param)")
  get "/dom/level5/" do |_|
    "<script>
            const urlParams = new URL(location.href).searchParams;
            const query = urlParams.get('query');
            eval(query)
        </script>"
  end

  Xssmaze.push("dom-level6", "/dom/level6/", "location.href (query param)")
  get "/dom/level6/" do |_|
    "<script>
            const urlParams = new URL(location.href).searchParams;
            const query = urlParams.get('query');
            document.location.href = query
        </script>"
  end
end
