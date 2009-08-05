def validate_admin_privileges
  api_key = params.delete("api_key")
  unless api_key
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  user = User.find(:first, :conditions => {
    'api_keys.api_key' => api_key
  })
  unless user
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
  unless user.admin
    error 401, { "errors" => ["unauthorized_api_key"] }.to_json
  end
end
