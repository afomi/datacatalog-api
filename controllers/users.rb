get '/users' do
  validate_admin_privileges
  users = User.find(:all)
  users.to_json
end

get '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  error 404, [].to_json unless user
  user.to_json
end

post '/users' do
  validate_admin_privileges
  id = params.delete("id")
  validate_user_params
  user = create_user_from_params
  user.to_json
end

put '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  error 404, [].to_json unless user
  validate_user_params
  user = User.update(id, params)
  user.to_json
end

delete '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  error 404, [].to_json unless user
  user.destroy
  { "id" => id }.to_json
end
