def load_csti_xss
  Xssmaze.push("csti-level1", "/csti/level1/?query=a", "AngularJS 1.x template injection via ng-app")
  maze_get "/csti/level1/" do |env|
    query = env.params.query["query"]

    "<html>
    <head><script src='https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.8.3/angular.min.js'></script></head>
    <body ng-app>
    <h1>CSTI Level 1</h1>
    <div>#{query}</div>
    </body></html>"
  end

  Xssmaze.push("csti-level2", "/csti/level2/?query=a", "AngularJS 1.x sandbox escape (older version)")
  maze_get "/csti/level2/" do |env|
    query = env.params.query["query"]

    "<html>
    <head><script src='https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.0/angular.min.js'></script></head>
    <body ng-app>
    <h1>CSTI Level 2</h1>
    <div>#{query}</div>
    </body></html>"
  end

  Xssmaze.push("csti-level3", "/csti/level3/?query=a", "Vue.js v-html directive injection")
  maze_get "/csti/level3/" do |env|
    query = env.params.query["query"]

    "<html>
    <head><script src='https://cdnjs.cloudflare.com/ajax/libs/vue/2.7.14/vue.min.js'></script></head>
    <body>
    <h1>CSTI Level 3</h1>
    <div id='app'>
      <div v-html='userInput'></div>
    </div>
    <script>
      new Vue({
        el: '#app',
        data: { userInput: '#{query}' }
      });
    </script>
    </body></html>"
  end

  Xssmaze.push("csti-level4", "/csti/level4/?query=a", "Vue.js template compilation injection")
  maze_get "/csti/level4/" do |env|
    query = env.params.query["query"]

    "<html>
    <head><script src='https://cdnjs.cloudflare.com/ajax/libs/vue/2.7.14/vue.min.js'></script></head>
    <body>
    <h1>CSTI Level 4</h1>
    <div id='app'>#{query}</div>
    <script>
      new Vue({ el: '#app' });
    </script>
    </body></html>"
  end

  Xssmaze.push("csti-level5", "/csti/level5/?query=a", "jQuery html() method injection")
  maze_get "/csti/level5/" do |env|
    query = env.params.query["query"]

    "<html>
    <head><script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script></head>
    <body>
    <h1>CSTI Level 5</h1>
    <div id='output'></div>
    <script>
      $('#output').html('#{query}');
    </script>
    </body></html>"
  end
end
