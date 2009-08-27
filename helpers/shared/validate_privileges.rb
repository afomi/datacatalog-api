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
  unless api_key
    @privileges = {
      :normal  => false,
      :owner   => false,
      :curator => false,
      :admin   => false
    }
    return hooks[:missing].call
  end
  user = User.find(:first, :conditions => {
    'api_keys.api_key' => api_key
  })
  unless user
    @privileges = {
      :normal  => false,
      :owner   => false,
      :curator => false,
      :admin   => false
    }
    return hooks[:invalid].call
  end
  if user.admin
    @privileges = {
      :normal  => true,
      :owner   => true,
      :curator => true,
      :admin   => true
    }
    return hooks[:admin].call
  end
  if user.curator
    @privileges = {
      :normal  => true,
      :owner   => true,
      :curator => true,
      :admin   => false
    }
    return hooks[:curator].call
  end
  if user_id && user_id == user.id
    @privileges = {
      :normal  => true,
      :owner   => true,
      :curator => true,
      :admin   => false
    }
    return hooks[:owner].call
  end
  @privileges = {
    :normal  => true,
    :owner   => false,
    :curator => false,
    :admin   => false
  }
  return hooks[:non_owner].call
end
