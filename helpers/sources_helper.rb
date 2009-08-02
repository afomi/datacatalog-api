def create_source_from_params
  source = Source.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/sources/' + source.id)
  source
end
