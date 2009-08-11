def validate_document_params
  validate_params Document, %w(
    created_at
    updated_at
  )
end

def create_document_from_params
  document = Document.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/documents/' + document.id)
  document
end
