def load_inframe_xss
    Xssmaze.push("inframe-xss-level1", "/inframe/level1/?url=a", "src attribute in iframe tag")
    get "/inframe/level1/" do |env|
      query = env.params.query["url"]
  
      "<iframe src='#{query}'></iframe>"
    end

    Xssmaze.push("inframe-xss-level2", "/inframe/level2/?url=a", "src attribute in iframe tag")
    get "/inframe/level2/" do |env|
      query = env.params.query["url"]
  
      "<iframe src='#{query.gsub("'","").gsub("\"","")}'></iframe>"
    end

    Xssmaze.push("inframe-xss-level3", "/inframe/level3/?url=a", "src attribute in iframe tag")
    get "/inframe/level3/" do |env|
      query = env.params.query["url"]
  
      "<iframe src='#{query.gsub("'","").gsub("\"","").downcase.gsub("javascript:","")}'></iframe>"
    end

    Xssmaze.push("inframe-xss-level4", "/inframe/level4/?url=a", "src attribute in iframe tag")
    get "/inframe/level4/" do |env|
      query = env.params.query["url"]
  
      "<iframe src='#{query.gsub("'","").gsub("\"","").downcase.gsub("javascript:","").gsub("alert","")}'></iframe>"
    end
end