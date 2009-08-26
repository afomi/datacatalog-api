def require_valid_api_key
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda {},
    :owner     => lambda {},
    :admin     => lambda {}
  })
end

def require_admin_or_owner(user_id)
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :owner     => lambda {},
    :admin     => lambda {}
  }, user_id)
end

def require_admin_privileges
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :owner     => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :admin     => lambda {}
  })
end

def check_api_key(hooks, user_id=nil)
  api_key = params.delete("api_key")
  return hooks[:missing].call unless api_key
  user = User.find(:first, :conditions => {
    'api_keys.api_key' => api_key
  })
  return hooks[:invalid].call unless user
  return hooks[:admin].call if user.admin
  return hooks[:owner].call if user_id && user_id == user.id
  return hooks[:non_owner].call
end
