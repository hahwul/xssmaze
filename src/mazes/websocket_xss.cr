def load_websocket_xss
  Xssmaze.push("websocket-xss-level1", "/websocket/level1/?query=a", "WebSocket message XSS (basic)")
  get "/websocket/level1/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 1</h1>
    <div id='messages'></div>
    <script>
      // Simulate WebSocket message
      function simulateMessage(data) {
        var messagesDiv = document.getElementById('messages');
        messagesDiv.innerHTML += '<div>Message: ' + data + '</div>';
      }

      // Simulate receiving a message with user input
      simulateMessage('#{query}');
    </script>
    </body></html>"
  end
  get "/websocket/level1" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 1</h1>
    <div id='messages'></div>
    <script>
      // Simulate WebSocket message
      function simulateMessage(data) {
        var messagesDiv = document.getElementById('messages');
        messagesDiv.innerHTML += '<div>Message: ' + data + '</div>';
      }

      // Simulate receiving a message with user input
      simulateMessage('#{query}');
    </script>
    </body></html>"
  end

  Xssmaze.push("websocket-xss-level2", "/websocket/level2/?query=a", "WebSocket JSON message XSS")
  get "/websocket/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 2</h1>
    <div id='messages'></div>
    <script>
      function handleMessage(jsonData) {
        var data = JSON.parse(jsonData);
        var messagesDiv = document.getElementById('messages');
        messagesDiv.innerHTML += '<div>User: ' + data.user + ', Message: ' + data.message + '</div>';
      }

      // Simulate JSON WebSocket message
      var messageData = '{\"user\": \"guest\", \"message\": \"#{query}\"}';
      handleMessage(messageData);
    </script>
    </body></html>"
  end
  get "/websocket/level2" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 2</h1>
    <div id='messages'></div>
    <script>
      function handleMessage(jsonData) {
        var data = JSON.parse(jsonData);
        var messagesDiv = document.getElementById('messages');
        messagesDiv.innerHTML += '<div>User: ' + data.user + ', Message: ' + data.message + '</div>';
      }

      // Simulate JSON WebSocket message
      var messageData = '{\"user\": \"guest\", \"message\": \"#{query}\"}';
      handleMessage(messageData);
    </script>
    </body></html>"
  end

  Xssmaze.push("websocket-xss-level3", "/websocket/level3/?query=a", "WebSocket with HTML message rendering")
  get "/websocket/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 3</h1>
    <div id='chat'></div>
    <script>
      function addChatMessage(user, message, isHtml) {
        var chatDiv = document.getElementById('chat');
        var messageDiv = document.createElement('div');

        if (isHtml) {
          messageDiv.innerHTML = '<strong>' + user + ':</strong> ' + message;
        } else {
          messageDiv.textContent = user + ': ' + message;
        }

        chatDiv.appendChild(messageDiv);
      }

      // Simulate HTML message (dangerous)
      addChatMessage('user123', '#{query}', true);
    </script>
    </body></html>"
  end
  get "/websocket/level3" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 3</h1>
    <div id='chat'></div>
    <script>
      function addChatMessage(user, message, isHtml) {
        var chatDiv = document.getElementById('chat');
        var messageDiv = document.createElement('div');

        if (isHtml) {
          messageDiv.innerHTML = '<strong>' + user + ':</strong> ' + message;
        } else {
          messageDiv.textContent = user + ': ' + message;
        }

        chatDiv.appendChild(messageDiv);
      }

      // Simulate HTML message (dangerous)
      addChatMessage('user123', '#{query}', true);
    </script>
    </body></html>"
  end

  Xssmaze.push("websocket-xss-level4", "/websocket/level4/?query=a", "WebSocket with eval-based message processing")
  get "/websocket/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 4</h1>
    <div id='output'></div>
    <script>
      function processCommand(command) {
        try {
          // Dangerous: evaluating WebSocket commands
          var result = eval(command);
          document.getElementById('output').innerHTML = 'Command result: ' + result;
        } catch(e) {
          document.getElementById('output').innerHTML = 'Error: ' + e.message;
        }
      }

      // Simulate command from WebSocket
      processCommand('\"#{query}\"');
    </script>
    </body></html>"
  end
  get "/websocket/level4" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 4</h1>
    <div id='output'></div>
    <script>
      function processCommand(command) {
        try {
          // Dangerous: evaluating WebSocket commands
          var result = eval(command);
          document.getElementById('output').innerHTML = 'Command result: ' + result;
        } catch(e) {
          document.getElementById('output').innerHTML = 'Error: ' + e.message;
        }
      }

      // Simulate command from WebSocket
      processCommand('\"#{query}\"');
    </script>
    </body></html>"
  end

  Xssmaze.push("websocket-xss-level5", "/websocket/level5/?query=a", "WebSocket with DOM manipulation")
  get "/websocket/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 5</h1>
    <div id='dynamic-content'></div>
    <script>
      function updateContent(elementId, content, attributes) {
        var element = document.getElementById(elementId);
        if (element) {
          element.innerHTML = content;
          // Apply attributes from WebSocket message
          for (var attr in attributes) {
            element.setAttribute(attr, attributes[attr]);
          }
        }
      }

      // Simulate WebSocket message with DOM manipulation
      var attributes = JSON.parse('{\"onclick\": \"#{query}\"}');
      updateContent('dynamic-content', 'Click me!', attributes);
    </script>
    </body></html>"
  end
  get "/websocket/level5" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>WebSocket XSS Level 5</h1>
    <div id='dynamic-content'></div>
    <script>
      function updateContent(elementId, content, attributes) {
        var element = document.getElementById(elementId);
        if (element) {
          element.innerHTML = content;
          // Apply attributes from WebSocket message
          for (var attr in attributes) {
            element.setAttribute(attr, attributes[attr]);
          }
        }
      }

      // Simulate WebSocket message with DOM manipulation
      var attributes = JSON.parse('{\"onclick\": \"#{query}\"}');
      updateContent('dynamic-content', 'Click me!', attributes);
    </script>
    </body></html>"
  end
end
