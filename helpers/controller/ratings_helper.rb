def validate_rating_params
  validate_params Rating, %w(
    created_at
  )
end

def create_rating_from_params
  document = Rating.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/ratings/' + document.id)
  document
end
