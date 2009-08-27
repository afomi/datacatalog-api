get '/tags' do
  require_admin
  tags = Tag.find(:all)
  tags.to_json
end

get '/tags/:id' do |id|
  require_admin
  id = params.delete("id")
  tag = Tag.find_by_id(id)
  error 404, [].to_json unless tag
  tag.to_json
end

post '/tags' do
  require_admin
  id = params.delete("id")
  validate_tag_params
  tag = create_tag_from_params
  tag.to_json
end

put '/tags/:id' do
  require_admin
  id = params.delete("id")
  tag = Tag.find_by_id(id)
  error 404, [].to_json unless tag
  validate_tag_params
  tag = Tag.update(id, params)
  tag.to_json
end

delete '/tags/:id' do
  require_admin
  id = params.delete("id")
  tag = Tag.find_by_id(id)
  error 404, [].to_json unless tag
  tag.destroy
  { "id" => id }.to_json
end
