def load_advanced_xss
  Xssmaze.push("advanced-xss-level1", "/advanced/level1/?query=a", "XSS with WAF bypass using encoding")
  get "/advanced/level1/" do |env|
    query = env.params.query["query"]
    # Simulate basic WAF filtering
    filtered_query = query.gsub("script", "").gsub("javascript", "").gsub("onload", "")

    "<html><body>
    <h1>Advanced XSS Level 1</h1>
    <div>Filtered input: #{filtered_query}</div>
    </body></html>"
  end
  get "/advanced/level1" do |env|
    query = env.params.query["query"]
    # Simulate basic WAF filtering
    filtered_query = query.gsub("script", "").gsub("javascript", "").gsub("onload", "")

    "<html><body>
    <h1>Advanced XSS Level 1</h1>
    <div>Filtered input: #{filtered_query}</div>
    </body></html>"
  end

  Xssmaze.push("advanced-xss-level2", "/advanced/level2/?query=a", "XSS with mutation observer")
  get "/advanced/level2/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 2</h1>
    <div id='target'></div>
    <script>
      var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'childList') {
            // Dangerous: processing mutations without sanitization
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === Node.TEXT_NODE) {
                var div = document.createElement('div');
                div.innerHTML = node.textContent;
                node.parentNode.replaceChild(div, node);
              }
            });
          }
        });
      });

      var target = document.getElementById('target');
      observer.observe(target, { childList: true, subtree: true });

      // Trigger mutation
      target.appendChild(document.createTextNode('#{query}'));
    </script>
    </body></html>"
  end
  get "/advanced/level2" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 2</h1>
    <div id='target'></div>
    <script>
      var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'childList') {
            // Dangerous: processing mutations without sanitization
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === Node.TEXT_NODE) {
                var div = document.createElement('div');
                div.innerHTML = node.textContent;
                node.parentNode.replaceChild(div, node);
              }
            });
          }
        });
      });

      var target = document.getElementById('target');
      observer.observe(target, { childList: true, subtree: true });

      // Trigger mutation
      target.appendChild(document.createTextNode('#{query}'));
    </script>
    </body></html>"
  end

  Xssmaze.push("advanced-xss-level3", "/advanced/level3/?query=a", "XSS with Service Worker")
  get "/advanced/level3/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 3</h1>
    <div id='content'></div>
    <script>
      if ('serviceWorker' in navigator) {
        // Simulate Service Worker message handling
        navigator.serviceWorker.addEventListener('message', function(event) {
          document.getElementById('content').innerHTML = 'SW Message: ' + event.data;
        });
      }

      // Simulate message from service worker
      var simulatedMessage = { data: '#{query}' };
      document.getElementById('content').innerHTML = 'SW Message: ' + simulatedMessage.data;
    </script>
    </body></html>"
  end
  get "/advanced/level3" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 3</h1>
    <div id='content'></div>
    <script>
      if ('serviceWorker' in navigator) {
        // Simulate Service Worker message handling
        navigator.serviceWorker.addEventListener('message', function(event) {
          document.getElementById('content').innerHTML = 'SW Message: ' + event.data;
        });
      }

      // Simulate message from service worker
      var simulatedMessage = { data: '#{query}' };
      document.getElementById('content').innerHTML = 'SW Message: ' + simulatedMessage.data;
    </script>
    </body></html>"
  end

  Xssmaze.push("advanced-xss-level4", "/advanced/level4/?query=a", "XSS with Web Components")
  get "/advanced/level4/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 4</h1>
    <div id='custom-component'></div>
    <script>
      class CustomElement extends HTMLElement {
        connectedCallback() {
          // Dangerous: direct innerHTML assignment
          this.innerHTML = '<div>Custom: #{query}</div>';
        }
      }

      if (!customElements.get('custom-element')) {
        customElements.define('custom-element', CustomElement);
      }

      document.getElementById('custom-component').innerHTML = '<custom-element></custom-element>';
    </script>
    </body></html>"
  end
  get "/advanced/level4" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 4</h1>
    <div id='custom-component'></div>
    <script>
      class CustomElement extends HTMLElement {
        connectedCallback() {
          // Dangerous: direct innerHTML assignment
          this.innerHTML = '<div>Custom: #{query}</div>';
        }
      }

      if (!customElements.get('custom-element')) {
        customElements.define('custom-element', CustomElement);
      }

      document.getElementById('custom-component').innerHTML = '<custom-element></custom-element>';
    </script>
    </body></html>"
  end

  Xssmaze.push("advanced-xss-level5", "/advanced/level5/?query=a", "XSS with Trusted Types bypass")
  get "/advanced/level5/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 5</h1>
    <div id='trusted-content'></div>
    <script>
      // Simulate Trusted Types bypass
      if (window.trustedTypes) {
        try {
          var policy = trustedTypes.createPolicy('myPolicy', {
            createHTML: function(input) {
              // Unsafe policy - allows all HTML
              return input;
            }
          });

          document.getElementById('trusted-content').innerHTML = policy.createHTML('#{query}');
        } catch (e) {
          // Fallback without Trusted Types
          document.getElementById('trusted-content').innerHTML = '#{query}';
        }
      } else {
        document.getElementById('trusted-content').innerHTML = '#{query}';
      }
    </script>
    </body></html>"
  end
  get "/advanced/level5" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 5</h1>
    <div id='trusted-content'></div>
    <script>
      // Simulate Trusted Types bypass
      if (window.trustedTypes) {
        try {
          var policy = trustedTypes.createPolicy('myPolicy', {
            createHTML: function(input) {
              // Unsafe policy - allows all HTML
              return input;
            }
          });

          document.getElementById('trusted-content').innerHTML = policy.createHTML('#{query}');
        } catch (e) {
          // Fallback without Trusted Types
          document.getElementById('trusted-content').innerHTML = '#{query}';
        }
      } else {
        document.getElementById('trusted-content').innerHTML = '#{query}';
      }
    </script>
    </body></html>"
  end

  Xssmaze.push("advanced-xss-level6", "/advanced/level6/?query=a", "XSS with Proxy object manipulation")
  get "/advanced/level6/" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 6</h1>
    <div id='proxy-content'></div>
    <script>
      var userInput = '#{query}';

      var handler = {
        get: function(target, prop) {
          if (prop === 'innerHTML') {
            return function(value) {
              // Dangerous: proxy allows bypassing protections
              target.innerHTML = value;
            };
          }
          return target[prop];
        }
      };

      var element = new Proxy(document.getElementById('proxy-content'), handler);
      element.innerHTML(userInput);
    </script>
    </body></html>"
  end
  get "/advanced/level6" do |env|
    query = env.params.query["query"]

    "<html><body>
    <h1>Advanced XSS Level 6</h1>
    <div id='proxy-content'></div>
    <script>
      var userInput = '#{query}';

      var handler = {
        get: function(target, prop) {
          if (prop === 'innerHTML') {
            return function(value) {
              // Dangerous: proxy allows bypassing protections
              target.innerHTML = value;
            };
          }
          return target[prop];
        }
      };

      var element = new Proxy(document.getElementById('proxy-content'), handler);
      element.innerHTML(userInput);
    </script>
    </body></html>"
  end
end
