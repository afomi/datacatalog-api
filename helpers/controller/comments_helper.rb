def validate_comment_params
  validate_params Comment, %w(
    created_at
    updated_at
  )
end

def create_comment_from_params
  document = Comment.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/comments/' + document.id)
  document
end
