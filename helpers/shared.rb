def full_uri(path)
  URI.join(APP_CONFIG['base_uri'], path).to_s
end
