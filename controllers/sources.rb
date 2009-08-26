get '/sources' do
  require_admin_privileges
  sources = Source.find(:all)
  sources.to_json
end

get '/sources/:id' do |id|
  require_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  error 404, [].to_json unless source
  source.to_json
end

post '/sources' do
  require_admin_privileges
  id = params.delete("id")
  validate_source_params
  source = create_source_from_params
  source.to_json
end

put '/sources/:id' do
  require_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  error 404, [].to_json unless source
  validate_source_params
  source = Source.update(id, params)
  source.to_json
end

delete '/sources/:id' do
  require_admin_privileges
  id = params.delete("id")
  source = Source.find_by_id(id)
  error 404, [].to_json unless source
  source.destroy
  { "id" => id }.to_json
end
