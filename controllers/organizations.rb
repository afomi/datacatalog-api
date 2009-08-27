get '/organizations' do
  require_valid_api_key
  organizations = Organization.find(:all)
  organizations.to_json
end

get '/organizations/:id' do |id|
  require_valid_api_key
  id = params.delete("id")
  organization = Organization.find_by_id(id)
  error 404, [].to_json unless organization
  organization.to_json
end

post '/organizations' do
  require_admin
  id = params.delete("id")
  validate_organization_params
  organization = create_organization_from_params
  organization.to_json
end

put '/organizations/:id' do
  require_admin
  id = params.delete("id")
  organization = Organization.find_by_id(id)
  error 404, [].to_json unless organization
  validate_organization_params
  organization = Organization.update(id, params)
  organization.to_json
end

delete '/organizations/:id' do
  require_admin
  id = params.delete("id")
  organization = Organization.find_by_id(id)
  error 404, [].to_json unless organization
  organization.destroy
  { "id" => id }.to_json
end
