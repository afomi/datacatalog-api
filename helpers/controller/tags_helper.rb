def validate_tag_params
  validate_params Note, %w(
    created_at
    updated_at
  )
end

def create_tag_from_params
  document = Tag.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/tags/' + document.id)
  document
end
