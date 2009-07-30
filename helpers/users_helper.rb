def validate_user_params
  all_keys = User.keys.keys
  invalid_keys = %w(
    api_key
    parent_api_key
    confirmed
  )
  valid_params = all_keys - invalid_keys
  invalid_params = params.keys - valid_params
  unless invalid_params.empty?
    content = {
      "errors" => { "invalid_params" => invalid_params }
    }
    error 400, content.to_json
  end
end

def create_user_from_params
  user = User.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/users/' + user.id)
  user
end
