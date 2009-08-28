def validate_rating_params
  validate_params Rating, %w(
    user_id
    created_at
    updated_at
  )
end

def create_rating_from_params
  params["user_id"] = @current_user.id
  document = Rating.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/ratings/' + document.id)
  document
end
