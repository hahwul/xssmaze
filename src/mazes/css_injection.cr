def load_css_injection
  Xssmaze.push("css-injection-level1", "/css/level1/?query=a", "CSS expression() XSS (IE)")
  get "/css/level1/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .user-style { 
      color: expression(#{query});
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 1</h1>
    <div class='user-style'>Styled content</div>
    </body></html>"
  end
  get "/css/level1" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .user-style { 
      color: expression(#{query});
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 1</h1>
    <div class='user-style'>Styled content</div>
    </body></html>"
  end

  Xssmaze.push("css-injection-level2", "/css/level2/?query=a", "CSS import with javascript: URL")
  get "/css/level2/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    @import url('#{query}');
    </style>
    </head><body>
    <h1>CSS Injection Level 2</h1>
    <div>Import-based CSS injection</div>
    </body></html>"
  end
  get "/css/level2" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    @import url('#{query}');
    </style>
    </head><body>
    <h1>CSS Injection Level 2</h1>
    <div>Import-based CSS injection</div>
    </body></html>"
  end

  Xssmaze.push("css-injection-level3", "/css/level3/?query=a", "CSS background-image with javascript: URL")
  get "/css/level3/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .bg { 
      background-image: url('#{query}');
      width: 100px;
      height: 100px;
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 3</h1>
    <div class='bg'></div>
    </body></html>"
  end
  get "/css/level3" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .bg { 
      background-image: url('#{query}');
      width: 100px;
      height: 100px;
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 3</h1>
    <div class='bg'></div>
    </body></html>"
  end

  Xssmaze.push("css-injection-level4", "/css/level4/?query=a", "CSS content property XSS")
  get "/css/level4/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .content::before { 
      content: '#{query}';
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 4</h1>
    <div class='content'>Content injection</div>
    </body></html>"
  end
  get "/css/level4" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .content::before { 
      content: '#{query}';
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 4</h1>
    <div class='content'>Content injection</div>
    </body></html>"
  end

  Xssmaze.push("css-injection-level5", "/css/level5/?query=a", "CSS keyframes animation XSS")
  get "/css/level5/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    @keyframes hack {
      0% { background: url('#{query}'); }
    }
    .animated { 
      animation: hack 1s;
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 5</h1>
    <div class='animated'>Animated element</div>
    </body></html>"
  end
  get "/css/level5" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    @keyframes hack {
      0% { background: url('#{query}'); }
    }
    .animated { 
      animation: hack 1s;
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 5</h1>
    <div class='animated'>Animated element</div>
    </body></html>"
  end

  Xssmaze.push("css-injection-level6", "/css/level6/?query=a", "CSS attr() function with HTML injection")
  get "/css/level6/" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .attr-content::after { 
      content: attr(data-content);
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 6</h1>
    <div class='attr-content' data-content='#{query}'>Element with attr content</div>
    </body></html>"
  end
  get "/css/level6" do |env|
    query = env.params.query["query"]
    
    "<html><head>
    <style>
    .attr-content::after { 
      content: attr(data-content);
    }
    </style>
    </head><body>
    <h1>CSS Injection Level 6</h1>
    <div class='attr-content' data-content='#{query}'>Element with attr content</div>
    </body></html>"
  end
end