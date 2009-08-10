get '/users/:user_id/keys' do
  validate_admin_privileges
  user_id = params.delete("user_id")
  user = User.find_by_id(user_id)
  error 404, [].to_json unless user
  user.api_keys.to_json
end

get '/users/:user_id/keys/:api_key_id' do
  validate_admin_privileges
  user_id = params.delete("user_id")
  api_key_id = params.delete("api_key_id")
  user = User.find_by_id(user_id)
  error 404, [].to_json unless user
  api_key = user.api_keys.find { |x| x.id == api_key_id }
  error 404, [].to_json unless api_key
  api_key.to_json
end

post '/users/:user_id/keys' do
  validate_admin_privileges
  user_id = params.delete("user_id")
  user = User.find_by_id(user_id)
  error 404, [].to_json unless user
  validate_api_key_params
  params["api_key"] = user.generate_api_key
  api_key = ApiKey.new(params)
  user.api_keys << api_key
  error 500, [].to_json unless user.save
  response.status = 201
  response.headers['Location'] = full_uri "/users/#{user_id}/keys/#{api_key.id}"
  api_key.to_json
end

put '/users/:user_id/keys/:api_key_id' do
  validate_admin_privileges
  user_id = params.delete("user_id")
  api_key_id = params.delete("api_key_id")
  user = User.find_by_id(user_id)
  error 404, [].to_json unless user
  validate_api_key_params
  api_key = user.api_keys.find { |x| x.id == api_key_id }
  error 404, [].to_json unless api_key
  api_key_index = user.api_keys.index(api_key)
  validate_api_key_params
  api_key.attributes = params
  user.api_keys[api_key_index] = api_key
  error 500, [].to_json unless user.save
  api_key.to_json
end

delete '/users/:user_id/keys/:api_key_id' do
  validate_admin_privileges
  user_id = params.delete("user_id")
  api_key_id = params.delete("api_key_id")
  user = User.find_by_id(user_id)
  error 404, [].to_json unless user
  keys = user.api_keys
  api_key = user.api_keys.find { |x| x.id == api_key_id }
  error 404, [].to_json unless api_key
  user.api_keys.delete(api_key)
  user.save!
  { "id" => api_key_id }.to_json
end
