def load_template_injection
  Xssmaze.push("template-injection-level1", "/template/level1/?query=a", "Server-side template injection (basic)")
  get "/template/level1/" do |env|
    query = env.params.query["query"]
    template = "Hello {{user_input}}"
    output = template.gsub("{{user_input}}", query)
    
    "<html><body>
    <h1>Template Injection Level 1</h1>
    <div>#{output}</div>
    </body></html>"
  end

  Xssmaze.push("template-injection-level2", "/template/level2/?query=a", "Client-side template injection (Handlebars style)")
  get "/template/level2/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>Template Injection Level 2</h1>
    <div id='output'></div>
    <script>
      var template = 'Hello {{user_input}}';
      var data = { user_input: '#{query}' };
      // Simulate simple template rendering
      var output = template.replace('{{user_input}}', data.user_input);
      document.getElementById('output').innerHTML = output;
    </script>
    </body></html>"
  end

  Xssmaze.push("template-injection-level3", "/template/level3/?query=a", "Template injection with expression evaluation")
  get "/template/level3/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>Template Injection Level 3</h1>
    <div id='output'></div>
    <script>
      var userExpression = '#{query}';
      // Dangerous: direct evaluation of user input as expression
      try {
        var result = eval('\"' + userExpression + '\"');
        document.getElementById('output').innerHTML = 'Result: ' + result;
      } catch(e) {
        document.getElementById('output').innerHTML = 'Error: ' + e.message;
      }
    </script>
    </body></html>"
  end

  Xssmaze.push("template-injection-level4", "/template/level4/?query=a", "Template injection with conditional rendering")
  get "/template/level4/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>Template Injection Level 4</h1>
    <div id='output'></div>
    <script>
      var condition = '#{query}';
      var template = condition ? 'Condition is true: ' + condition : 'Condition is false';
      document.getElementById('output').innerHTML = template;
    </script>
    </body></html>"
  end

  Xssmaze.push("template-injection-level5", "/template/level5/?query=a", "Template injection with loop rendering")
  get "/template/level5/" do |env|
    query = env.params.query["query"]
    
    "<html><body>
    <h1>Template Injection Level 5</h1>
    <div id='output'></div>
    <script>
      var items = ['#{query}'];
      var output = '';
      for(var i = 0; i < items.length; i++) {
        output += '<li>' + items[i] + '</li>';
      }
      document.getElementById('output').innerHTML = '<ul>' + output + '</ul>';
    </script>
    </body></html>"
  end

  Xssmaze.push("template-injection-level6", "/template/level6/?query=a", "Template injection with sanitization bypass")
  get "/template/level6/" do |env|
    query = env.params.query["query"].gsub("<script", "&lt;script").gsub("</script>", "&lt;/script&gt;")
    
    "<html><body>
    <h1>Template Injection Level 6</h1>
    <div id='output'></div>
    <script>
      // Even with script tag filtering, other vectors exist
      var userInput = '#{query}';
      document.getElementById('output').innerHTML = 'User said: ' + userInput;
    </script>
    </body></html>"
  end
end