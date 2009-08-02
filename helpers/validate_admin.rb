def validate_admin_privileges
  api_key = params.delete("api_key")
  unless api_key
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  client = User.find(:first, :conditions => { :api_key => api_key })
  unless client
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
  unless client.admin
    error 401, { "errors" => ["unauthorized_api_key"] }.to_json
  end
end
