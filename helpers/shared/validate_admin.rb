def validate_admin_privileges
  check_api_key({
    :missing => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :normal  => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :admin   => lambda {}
  })
end

def check_api_key(hooks)
  api_key = params.delete("api_key")
  unless api_key
    return hooks[:missing].call
  end
  user = User.find(:first, :conditions => {
    'api_keys.api_key' => api_key
  })
  unless user
    return hooks[:invalid].call
  end
  unless user.admin
    return hooks[:normal].call
  end
  hooks[:admin].call
end
