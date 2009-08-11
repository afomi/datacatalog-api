def validate_source_params
  validate_params Source, %w(
    created_at
    updated_at
  )
end

def create_source_from_params
  source = Source.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/sources/' + source.id)
  source
end
