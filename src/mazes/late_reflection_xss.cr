def load_late_reflection_xss
  # Level 1: 500 chars of HTML before reflection in div
  Xssmaze.push("latereflect-level1", "/latereflect/level1/?query=a", "500 chars of HTML before reflection in div")
  maze_get "/latereflect/level1/" do |env|
    query = env.params.query["query"]
    padding = "<div class=\"wrapper\"><header><h1>Welcome to Our Application</h1><p>This is a comprehensive platform designed to help users manage their data efficiently.</p></header><nav><ul><li><a href=\"/home\">Home</a></li><li><a href=\"/about\">About</a></li><li><a href=\"/services\">Services</a></li><li><a href=\"/contact\">Contact</a></li></ul></nav><section class=\"intro\"><p>We provide excellent services for all your needs. Our team is dedicated to delivering quality results.</p></section></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{padding}
<div>#{query}</div>
</body></html>"
  end

  # Level 2: 1000 chars of HTML before reflection in p
  Xssmaze.push("latereflect-level2", "/latereflect/level2/?query=a", "1000 chars of HTML before reflection in p tag")
  maze_get "/latereflect/level2/" do |env|
    query = env.params.query["query"]
    padding = "<div class=\"wrapper\"><header><h1>Welcome to Our Application Portal</h1><p>This is a comprehensive platform designed to help users manage their data efficiently and securely.</p></header><nav><ul><li><a href=\"/home\">Home</a></li><li><a href=\"/about\">About Us</a></li><li><a href=\"/services\">Services</a></li><li><a href=\"/products\">Products</a></li><li><a href=\"/contact\">Contact</a></li><li><a href=\"/support\">Support</a></li></ul></nav><section class=\"intro\"><p>We provide excellent services for all your needs. Our team of professionals is dedicated to delivering quality results on time and within budget.</p><p>Founded in 2020, we have grown to serve thousands of customers worldwide with innovative solutions and cutting-edge technology.</p></section><aside class=\"sidebar\"><h3>Latest News</h3><ul><li>New feature released this week</li><li>Quarterly report now available</li><li>Maintenance scheduled for next weekend</li></ul></aside><section class=\"features\"><h2>Key Features</h2><p>Our platform includes real-time analytics, automated reporting, team collaboration tools, and enterprise-grade security.</p></section></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{padding}
<p>#{query}</p>
</body></html>"
  end

  # Level 3: 2000 chars of HTML before reflection in input value
  Xssmaze.push("latereflect-level3", "/latereflect/level3/?query=a", "2000 chars of HTML before reflection in input value")
  maze_get "/latereflect/level3/" do |env|
    query = env.params.query["query"]
    block_a = "<div class=\"section-alpha\"><header><h1>Enterprise Dashboard Portal</h1><p>Manage your organization resources, teams, and analytics from one centralized location.</p></header><nav class=\"main-nav\"><ul><li><a href=\"/home\">Home</a></li><li><a href=\"/dashboard\">Dashboard</a></li><li><a href=\"/reports\">Reports</a></li><li><a href=\"/analytics\">Analytics</a></li><li><a href=\"/settings\">Settings</a></li><li><a href=\"/profile\">Profile</a></li><li><a href=\"/logout\">Logout</a></li></ul></nav></div>"
    block_b = "<div class=\"section-beta\"><aside class=\"sidebar-left\"><h3>Quick Links</h3><ul><li><a href=\"/docs\">Documentation</a></li><li><a href=\"/api\">API Reference</a></li><li><a href=\"/changelog\">Changelog</a></li><li><a href=\"/status\">System Status</a></li></ul><h3>Recent Activity</h3><p>User John updated report #4521 at 14:32 UTC. Admin created new team 'Engineering'. System backup completed successfully at 03:00 UTC.</p></aside></div>"
    block_c = "<div class=\"section-gamma\"><section class=\"content-area\"><h2>Platform Overview</h2><p>Our enterprise platform provides comprehensive tools for data management, team collaboration, and business intelligence. With real-time dashboards, automated workflows, and granular access controls, teams can work efficiently and securely.</p><p>Key capabilities include advanced reporting with customizable templates, integration with over 200 third-party services, role-based access management, audit logging, and compliance monitoring for SOC2 and ISO 27001 standards.</p><table class=\"stats\"><thead><tr><th>Metric</th><th>Value</th><th>Change</th></tr></thead><tbody><tr><td>Active Users</td><td>12,450</td><td>+5.2%</td></tr><tr><td>Reports Generated</td><td>89,231</td><td>+12.1%</td></tr><tr><td>API Calls</td><td>2.4M</td><td>+8.7%</td></tr></tbody></table></section></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{block_a}
#{block_b}
#{block_c}
<div class=\"search-box\"><input type=\"text\" value=\"#{query}\"></div>
</body></html>"
  end

  # Level 4: Reflection sandwiched between two 500-char blocks
  Xssmaze.push("latereflect-level4", "/latereflect/level4/?query=a", "reflection between two 500-char HTML blocks")
  maze_get "/latereflect/level4/" do |env|
    query = env.params.query["query"]
    before_block = "<div class=\"before-content\"><header><h1>Application Framework Portal</h1><p>This platform provides tools for managing enterprise resources, analytics dashboards, and team collaboration features.</p></header><nav><ul><li><a href=\"/home\">Home</a></li><li><a href=\"/about\">About</a></li><li><a href=\"/services\">Services</a></li><li><a href=\"/contact\">Contact</a></li></ul></nav><section class=\"intro\"><p>We deliver excellence in every project. Our professionals ensure quality results with timely delivery.</p></section></div>"
    after_block = "<div class=\"after-content\"><section class=\"footer-info\"><h2>Additional Resources</h2><p>Explore our comprehensive documentation, tutorials, and knowledge base articles to get the most out of our platform.</p><ul><li><a href=\"/docs\">Documentation</a></li><li><a href=\"/tutorials\">Tutorials</a></li><li><a href=\"/faq\">FAQ</a></li><li><a href=\"/community\">Community Forum</a></li></ul></section><footer><p>Copyright 2026 Enterprise Solutions Inc. All rights reserved. Terms of Service and Privacy Policy apply.</p></footer></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{before_block}
<div class=\"result\">#{query}</div>
#{after_block}
</body></html>"
  end

  # Level 5: 3000 chars of HTML before reflection in span
  Xssmaze.push("latereflect-level5", "/latereflect/level5/?query=a", "3000 chars of HTML before reflection in span")
  maze_get "/latereflect/level5/" do |env|
    query = env.params.query["query"]
    block_a = "<div class=\"mega-header\"><header><h1>Global Enterprise Management System</h1><p>A comprehensive solution for managing worldwide operations, resources, and strategic business initiatives across all departments.</p></header><nav class=\"primary-nav\"><ul><li><a href=\"/home\">Home</a></li><li><a href=\"/dashboard\">Dashboard</a></li><li><a href=\"/projects\">Projects</a></li><li><a href=\"/teams\">Teams</a></li><li><a href=\"/reports\">Reports</a></li><li><a href=\"/settings\">Settings</a></li></ul></nav></div>"
    block_b = "<div class=\"mega-sidebar\"><aside><h3>Navigation</h3><ul><li><a href=\"/docs\">Documentation</a></li><li><a href=\"/api\">API</a></li><li><a href=\"/changelog\">Changelog</a></li><li><a href=\"/status\">Status</a></li><li><a href=\"/security\">Security</a></li></ul><h3>Recent Updates</h3><p>System maintenance completed. Performance improvements deployed to production cluster. Database migration finished at 02:00 UTC with zero downtime.</p><h3>Notifications</h3><p>You have 3 unread messages. Team review meeting scheduled for Friday. Quarterly report deadline approaching next week.</p></aside></div>"
    block_c = "<div class=\"mega-content\"><section class=\"overview\"><h2>System Overview</h2><p>The enterprise management system provides real-time analytics, automated workflows, compliance monitoring, and comprehensive audit trails. Our platform integrates with over 300 third-party services including cloud providers, CRM systems, and communication tools.</p><p>Advanced features include machine learning powered anomaly detection, predictive analytics for resource planning, automated incident response workflows, and customizable dashboards with drag-and-drop widget placement.</p></section><section class=\"metrics\"><h2>Performance Metrics</h2><table><thead><tr><th>Metric</th><th>Current</th><th>Previous</th><th>Change</th></tr></thead><tbody><tr><td>Response Time</td><td>45ms</td><td>52ms</td><td>-13.5%</td></tr><tr><td>Uptime</td><td>99.97%</td><td>99.95%</td><td>+0.02%</td></tr><tr><td>Active Sessions</td><td>8,432</td><td>7,891</td><td>+6.9%</td></tr><tr><td>Error Rate</td><td>0.03%</td><td>0.05%</td><td>-40.0%</td></tr></tbody></table></section></div>"
    block_d = "<div class=\"mega-footer-area\"><section class=\"announcements\"><h2>Announcements</h2><p>Version 4.2 has been released with new collaboration features, improved search functionality, and enhanced security protocols.</p><p>The annual user conference will be held on September 15-17. Register early for the best rates. Keynote speakers from industry leaders will present on topics including AI-driven automation and cloud-native architectures.</p></section></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{block_a}
#{block_b}
#{block_c}
#{block_d}
<span>#{query}</span>
</body></html>"
  end

  # Level 6: 5000 chars of HTML before reflection in deep div
  Xssmaze.push("latereflect-level6", "/latereflect/level6/?query=a", "5000 chars of HTML before reflection in deep div")
  maze_get "/latereflect/level6/" do |env|
    query = env.params.query["query"]
    block_a = "<div class=\"ultra-header\"><header class=\"site-header\"><h1>International Enterprise Resource Planning System</h1><p>Providing world-class solutions for organizations of all sizes across every industry sector and geographic region.</p><p>Our platform has been trusted by Fortune 500 companies for over a decade, delivering consistent results and exceptional reliability.</p></header><nav class=\"main-navigation\"><ul class=\"nav-list\"><li><a href=\"/home\">Home</a></li><li><a href=\"/dashboard\">Dashboard</a></li><li><a href=\"/projects\">Projects</a></li><li><a href=\"/resources\">Resources</a></li><li><a href=\"/analytics\">Analytics</a></li><li><a href=\"/reports\">Reports</a></li><li><a href=\"/admin\">Administration</a></li><li><a href=\"/settings\">Settings</a></li><li><a href=\"/help\">Help Center</a></li></ul></nav></div>"
    block_b = "<div class=\"ultra-sidebar\"><aside class=\"left-sidebar\"><div class=\"widget\"><h3>Quick Actions</h3><ul><li><a href=\"/new-project\">Create Project</a></li><li><a href=\"/new-report\">Generate Report</a></li><li><a href=\"/invite\">Invite Team Member</a></li><li><a href=\"/export\">Export Data</a></li></ul></div><div class=\"widget\"><h3>System Health</h3><p>All systems operational. Last check: 2 minutes ago. CPU usage: 34%. Memory: 62%. Disk: 45%. Network latency: 12ms average across all regions.</p></div><div class=\"widget\"><h3>Recent Activity Feed</h3><ul><li>Admin updated security policy at 14:22 UTC</li><li>John created project 'Q4 Planning' at 13:45 UTC</li><li>Sarah submitted expense report #8921 at 12:30 UTC</li><li>System backup completed at 03:00 UTC</li><li>New user registration: maria@example.com at 11:15 UTC</li></ul></div></aside></div>"
    block_c = "<div class=\"ultra-content-main\"><section class=\"content-primary\"><h2>Platform Capabilities Overview</h2><p>Our enterprise resource planning system delivers comprehensive functionality spanning project management, financial operations, human resources, supply chain management, and customer relationship management. The modular architecture allows organizations to deploy only the components they need while maintaining seamless integration across all modules.</p><p>Key differentiators include real-time data synchronization across global offices, AI-powered demand forecasting with 95% accuracy, automated compliance monitoring for SOC2, ISO 27001, GDPR, and HIPAA standards, and a extensible plugin ecosystem with over 500 verified integrations.</p><p>The analytics engine processes millions of data points per second, delivering insights through customizable dashboards, scheduled reports, and intelligent alerts that help leadership make data-driven decisions faster than ever before.</p></section></div>"
    block_d = "<div class=\"ultra-content-secondary\"><section class=\"metrics-dashboard\"><h2>Organizational Metrics Dashboard</h2><table class=\"data-table\"><thead><tr><th>Department</th><th>Projects</th><th>Budget Used</th><th>Completion Rate</th><th>Satisfaction</th></tr></thead><tbody><tr><td>Engineering</td><td>42</td><td>78%</td><td>91%</td><td>4.5/5</td></tr><tr><td>Marketing</td><td>28</td><td>65%</td><td>87%</td><td>4.3/5</td></tr><tr><td>Sales</td><td>35</td><td>82%</td><td>94%</td><td>4.7/5</td></tr><tr><td>Operations</td><td>19</td><td>71%</td><td>89%</td><td>4.4/5</td></tr><tr><td>Finance</td><td>15</td><td>58%</td><td>96%</td><td>4.6/5</td></tr></tbody></table></section><section class=\"team-updates\"><h2>Team Updates and Announcements</h2><p>The engineering team has completed the migration to the new microservices architecture, resulting in a 40% improvement in API response times and a 60% reduction in deployment frequency incidents.</p><p>Marketing launched the new brand campaign across 12 markets simultaneously, achieving record engagement metrics in the first week. The A/B testing framework identified winning variants 3x faster than previous campaigns.</p><p>The sales department exceeded Q3 targets by 15%, with the new AI-assisted lead scoring system contributing to a 25% increase in qualified opportunity generation.</p></section></div>"
    block_e = "<div class=\"ultra-footer-section\"><section class=\"resources-section\"><h2>Knowledge Base and Resources</h2><div class=\"resource-grid\"><div class=\"resource-card\"><h3>Getting Started Guide</h3><p>New to the platform? Our comprehensive onboarding guide covers everything from initial setup to advanced configuration.</p></div><div class=\"resource-card\"><h3>API Documentation</h3><p>Complete reference for all REST API endpoints including authentication, rate limits, and code examples in Python, JavaScript, and Go.</p></div><div class=\"resource-card\"><h3>Best Practices</h3><p>Learn from industry experts with our curated collection of best practices for project management, data governance, and security.</p></div><div class=\"resource-card\"><h3>Video Tutorials</h3><p>Over 200 hours of video content covering basic to advanced topics, updated monthly with the latest features and workflows.</p></div></div></section><footer class=\"site-footer\"><p>Copyright 2026 International Enterprise Solutions Corporation. All rights reserved worldwide.</p><p>Terms of Service | Privacy Policy | Cookie Policy | Accessibility Statement | Security | Contact Us</p></footer></div>"

    "<!DOCTYPE html>
<html><head><meta charset=\"UTF-8\"><title>Page</title></head>
<body>
#{block_a}
#{block_b}
#{block_c}
#{block_d}
#{block_e}
<div id=\"deep\">#{query}</div>
</body></html>"
  end
end
