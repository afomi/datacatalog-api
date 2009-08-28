get '/ratings' do
  require_valid_api_key
  ratings = Rating.find(:all)
  ratings.to_json
end

get '/ratings/:id' do |id|
  require_valid_api_key
  id = params.delete("id")
  rating = Rating.find_by_id(id)
  error 404, [].to_json unless rating
  rating.to_json
end

post '/ratings' do
  require_valid_api_key
  id = params.delete("id")
  validate_rating_params
  rating = create_rating_from_params
  rating.to_json
end

put '/ratings/:id' do
  require_curator_or_higher
  id = params.delete("id")
  rating = Rating.find_by_id(id)
  error 404, [].to_json unless rating
  validate_rating_params
  rating = Rating.update(id, params)
  rating.to_json
end

delete '/ratings/:id' do
  require_curator_or_higher
  id = params.delete("id")
  rating = Rating.find_by_id(id)
  error 404, [].to_json unless rating
  rating.destroy
  { "id" => id }.to_json
end
