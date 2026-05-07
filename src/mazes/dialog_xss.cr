def load_dialog_xss
  Xssmaze.push("dialog-level1", "/dialog/level1/?query=a", "raw query inside <dialog open> element")
  maze_get "/dialog/level1/" do |env|
    query = env.params.query["query"]
    "<dialog open>#{query}</dialog>"
  end

  Xssmaze.push("dialog-level2", "/dialog/level2/?query=a", "query reflected as <dialog> id")
  maze_get "/dialog/level2/" do |env|
    query = env.params.query["query"]
    "<dialog open id='#{query}'>hello</dialog>"
  end

  Xssmaze.push("dialog-level3", "/dialog/level3/?query=a", "query as form returnValue inside dialog")
  maze_get "/dialog/level3/" do |env|
    query = env.params.query["query"]
    "<dialog open>
      <form method='dialog'>
        <input name='val' value='#{query}'>
        <button value='#{query}'>close</button>
      </form>
    </dialog>"
  end

  Xssmaze.push("dialog-level4", "/dialog/level4/?query=a", "showModal trigger with query as innerHTML")
  maze_get "/dialog/level4/" do |env|
    query = env.params.query["query"]
    "<dialog id='d'></dialog>
     <script>
       var d = document.getElementById('d');
       d.innerHTML = #{query.to_json};
       d.showModal();
     </script>"
  end

  Xssmaze.push("dialog-level5", "/dialog/level5/?query=a", "<dialog> with filtered <script> tag (case bypass)")
  maze_get "/dialog/level5/" do |env|
    query = env.params.query["query"].gsub("<script>", "").gsub("</script>", "")
    "<dialog open>#{query}</dialog>"
  end
end
