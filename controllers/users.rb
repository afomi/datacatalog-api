get '/users' do
  validate_admin_privileges
  users = User.find(:all)
  jsonify users
end

get '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  if user
    jsonify user
  else
    error 404, [].to_json
  end
end

post '/users' do
  validate_admin_privileges
  id = params.delete("id")
  validate_user_params
  user = create_user_from_params
  jsonify user
end

put '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  unless user
    error 404, [].to_json
  end
  validate_user_params
  user = User.update(id, params)
  jsonify user
end

delete '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  user.destroy
  { "id" => id }.to_json
end
