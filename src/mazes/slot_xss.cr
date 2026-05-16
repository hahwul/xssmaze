Xssmaze.push("slot-level1", "/slot/level1/?query=a", "shadow DOM <slot> content unfiltered (light DOM reflection)")
maze_get "/slot/level1/" do |env|
  query = env.params.query["query"]
  "<x-card>#{query}</x-card>
   <script>
     customElements.define('x-card', class extends HTMLElement {
       constructor() {
         super();
         this.attachShadow({mode: 'open'}).innerHTML = '<style>::slotted(*){color:#333}</style><div><slot></slot></div>';
       }
     });
   </script>"
end

Xssmaze.push("slot-level2", "/slot/level2/?query=a", "named slot reflected into element attribute")
maze_get "/slot/level2/" do |env|
  query = env.params.query["query"]
  "<x-tab><span slot='#{query}'>tab body</span></x-tab>
   <script>
     customElements.define('x-tab', class extends HTMLElement {
       constructor() {
         super();
         this.attachShadow({mode: 'open'}).innerHTML = '<slot name=\"a\"></slot><slot name=\"b\"></slot>';
       }
     });
   </script>"
end

Xssmaze.push("slot-level3", "/slot/level3/?query=a", "slotchange handler innerHTMLs assignedNodes")
maze_get "/slot/level3/" do |env|
  query = env.params.query["query"]
  "<x-list>#{query}</x-list>
   <script>
     customElements.define('x-list', class extends HTMLElement {
       constructor() {
         super();
         var s = this.attachShadow({mode: 'open'});
         s.innerHTML = '<div id=\"out\"></div><slot></slot>';
         s.querySelector('slot').addEventListener('slotchange', function (e) {
           var nodes = e.target.assignedNodes();
           s.querySelector('#out').innerHTML = nodes.map(function (n) { return n.textContent; }).join('');
         });
       }
     });
   </script>"
end

Xssmaze.push("slot-level4", "/slot/level4/?query=a", "shadow root opens with mode=open, host innerHTML sink")
maze_get "/slot/level4/" do |env|
  query = env.params.query["query"]
  "<x-host></x-host>
   <script>
     var el = document.querySelector('x-host');
     el.attachShadow({mode: 'open'}).innerHTML = '<div>' + #{query.to_json} + '</div>';
   </script>"
end
