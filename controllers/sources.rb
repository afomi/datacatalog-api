get '/sources' do
  validate_admin_privileges
  sources = Source.find(:all)
  sources.to_json
end

get '/sources/:id' do |id|
  validate_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  if source
    source.to_json
  else
    error 404, [].to_json
  end
end

post '/sources' do
  validate_admin_privileges
  id = params.delete("id")
  validate_source_params
  source = create_source_from_params
  source.to_json
end

put '/sources/:id' do
  validate_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  unless source
    error 404, [].to_json
  end
  validate_source_params
  source = Source.update(id, params)
  source.to_json
end

delete '/sources/:id' do
  validate_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  unless source
    error 404, [].to_json
  end
  source.destroy
  { "id" => id }.to_json
end
