def require_valid_api_key
  @privileges = privileges_for_api_key
  if @privileges[:anonymous]
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  unless @privileges[:basic]
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
end

def require_owner_or_higher(user_id)
  @privileges = privileges_for_api_key(user_id)
  if @privileges[:anonymous]
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  unless @privileges[:basic]
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
  unless @privileges[:owner]
    error 401, { "errors" => ["unauthorized_api_key"] }.to_json
  end
end

def require_curator_or_higher
  @privileges = privileges_for_api_key
  if @privileges[:anonymous]
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  unless @privileges[:basic]
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
  unless @privileges[:curator]
    error 401, { "errors" => ["unauthorized_api_key"] }.to_json
  end
end

def require_admin
  @privileges = privileges_for_api_key
  if @privileges[:anonymous]
    error 401, { "errors" => ["missing_api_key"] }.to_json
  end
  unless @privileges[:basic]
    error 401, { "errors" => ["invalid_api_key"] }.to_json
  end
  unless @privileges[:admin]
    error 401, { "errors" => ["unauthorized_api_key"] }.to_json
  end
end

def privileges_for_api_key(user_id=nil)
  default = {
    :anonymous => false,
    :basic     => false,
    :owner     => false,
    :curator   => false,
    :admin     => false
  }
  api_key = params.delete("api_key")
  unless api_key
    return default.merge(:anonymous => true)
  end
  @current_user = User.find(:first, :conditions => { 'api_keys.api_key' => api_key })
  unless @current_user
    return default
  end
  if @current_user.admin
    return default.merge(:admin => true, :curator => true, :owner => true, :basic => true)
  end
  if @current_user.curator
    return default.merge(:curator => true, :owner => true, :basic => true)
  end
  if user_id && user_id == @current_user.id
    return default.merge(:owner => true, :basic => true)
  end
  default.merge(:basic => true)
end
