def full_uri(path)
  base_uri = Sinatra::Application.config["base_uri"]
  URI.join(base_uri, path).to_s
end
