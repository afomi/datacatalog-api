def validate_note_params
  validate_params Note, %w(
    created_at
    updated_at
  )
end

def create_note_from_params
  document = Note.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/notes/' + document.id)
  document
end
