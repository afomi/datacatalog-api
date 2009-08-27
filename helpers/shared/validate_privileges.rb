def require_valid_api_key
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda {},
    :owner     => lambda {},
    :curator   => lambda {},
    :admin     => lambda {}
  })
end

def require_owner_or_higher(user_id)
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :owner     => lambda {},
    :curator   => lambda {},
    :admin     => lambda {}
  }, user_id)
end

def require_curator_or_higher
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :owner     => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :curator   => lambda {},
    :admin     => lambda {}
  })
end

def require_admin
  check_api_key({
    :missing   => lambda { error 401, { "errors" => ["missing_api_key"] }.to_json },
    :invalid   => lambda { error 401, { "errors" => ["invalid_api_key"] }.to_json },
    :non_owner => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :owner     => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
    :curator   => lambda { error 401, { "errors" => ["unauthorized_api_key"] }.to_json },
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
  return hooks[:curator].call if user.curator
  return hooks[:owner].call if user_id && user_id == user.id
  return hooks[:non_owner].call
end
