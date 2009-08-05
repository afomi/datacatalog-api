def create_user_from_params
  user = User.create(params)
  user.add_api_key!
  response.status = 201
  response.headers['Location'] = full_uri('/users/' + user.id)
  user
end
