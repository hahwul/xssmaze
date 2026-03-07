macro maze_get(path, &block)
  get {{path}} {{block}}
  {% if path.ends_with?("/") %}
    get {{path[0...-1]}} {{block}}
  {% end %}
end

macro maze_post(path, &block)
  post {{path}} {{block}}
  {% if path.ends_with?("/") %}
    post {{path[0...-1]}} {{block}}
  {% end %}
end
